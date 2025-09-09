//
//  NewPillStepOneViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 07.04.2025.
//

import UIKit

final class NewPillStepOneViewController: BaseStepViewController {
    
    // MARK: - Public Properties
    let viewModel = NewPillStepOneViewModel()
    
    lazy var titleTextField: UITextField = {
        let tf = createTextField(placeholder: "Введите название", delegate: self)
        tf.returnKeyType = .next
        tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return tf
    }()
    
    lazy var dosageTextField: UITextField = {
        let tf = createTextField(placeholder: "Введите дозировку", keyboardType: .decimalPad, delegate: self)
        tf.returnKeyType = .done
        tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return tf
    }()
    
    lazy var unitButton = createButton(title: "Выберите единицу", target: self, action: #selector(didTapUnitButton))
    
    lazy var formTypesButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(named: "photoCamera"), for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(didTapFormTypesButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Private Properties
    private lazy var titleLabel = createLabel(text: "Название")
    private lazy var dosageLabel = createLabel(text: "Дозировка")
        
    private lazy var spacerView: UIView = {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 10).isActive = true
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [formTypesButton, titleLabel, titleTextField, dosageLabel, dosageTextField, spacerView, unitButton])
         stackView.axis = .vertical
         stackView.spacing = 20
        stackView.distribution = .equalSpacing
         stackView.translatesAutoresizingMaskIntoConstraints = false
         return stackView
     }()
    
    private var keyboardWillShowObserver: NSObjectProtocol?
    private var keyboardWillHideObserver: NSObjectProtocol?
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - IB Actions
    @objc
    private func didTapFormTypesButton() {
        formTypesButton.animatePress()
        viewModel.handleFormTypesButtonTap(presenter: self)
    }
    
    @objc
    private func didTapUnitButton() {
        unitButton.animatePress()
        viewModel.handleUnitButtonTap(presenter: self)
    }
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        if textField == titleTextField {
            viewModel.pillStepOneModel.title = textField.text
        } else if textField == dosageTextField {
            if let dosageText = textField.text, let dosageValue = Double(dosageText) {
                viewModel.dosage = dosageValue
                viewModel.pillStepOneModel.dosage = dosageValue
            } else {
                viewModel.dosage = 0
                viewModel.pillStepOneModel.dosage = nil
            }
        }
        viewModel.checkValidity()
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height

        UIView.animate(withDuration: 0.3) {
            self.stackView.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight / 2)
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.stackView.transform = .identity
        }
    }
    
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .white
            
        setupTextFields()
        setupBindings()
        loadData()

        view.addSubview(stackView)
        addConstraint()
        setupKeyboardObservers()

    }
    
    private func addConstraint() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            formTypesButton.heightAnchor.constraint(equalToConstant: 120),
            
            titleTextField.heightAnchor.constraint(equalToConstant: 60),
            dosageTextField.heightAnchor.constraint(equalToConstant: 60),
            
            unitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupBindings() {
        viewModel.updateIconButton = { [weak self] icon in
            self?.animateIconChange(to: icon)
        }
        
        viewModel.updateUnitButtonTitle = { [weak self] in
            guard let self = self else { return }
            
            if let selectedUnit = self.viewModel.selectedUnit {
                let unitTitle = String.getUnitTitle(for: self.viewModel.dosage, unit: selectedUnit)
                self.unitButton.setTitle(unitTitle, for: .normal)
            } else {
                self.unitButton.setTitle("Выберите единицу", for: .normal)
            }
        }
        
        viewModel.onValidationChange = { [weak self] isValid in
            self?.updateButtonState(isEnabled: isValid, isNextButton: true)
        }
    }
    
    private func setupKeyboardObservers() {
        keyboardWillShowObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { [weak self] notification in
            self?.keyboardWillShow(notification: notification)
        }
        keyboardWillHideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] notification in
            self?.keyboardWillHide(notification: notification)
        }
    }
    
    deinit {
        if let observer = keyboardWillShowObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = keyboardWillHideObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func setupTextFields() {
        titleTextField.returnKeyType = .next
        dosageTextField.returnKeyType = .done
    }
    
    func loadData() {
        if let selectedIcon = viewModel.pillStepOneModel.selectedIcon {
            formTypesButton.setImage(selectedIcon, for: .normal)
        }
        
        titleTextField.text = viewModel.pillStepOneModel.title
        
        if let dosage = viewModel.pillStepOneModel.dosage {
            dosageTextField.text = String(format: "%.1f", dosage)
        } else {
            dosageTextField.text = nil
        }
        
        if let selectedUnit = viewModel.pillStepOneModel.selectedUnit {
            self.viewModel.selectedUnit = selectedUnit
            unitButton.setTitle(selectedUnit, for: .normal)
        }
        
        viewModel.checkValidity()
    }
    
    private func animateIconChange(to newIcon: UIImage?) {
        UIView.transition(with: formTypesButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.formTypesButton.setImage(newIcon, for: .normal)
        }, completion: nil)
    }
}

// MARK: UITextFieldDelegate
extension NewPillStepOneViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == dosageTextField {
            return viewModel.shouldChangeCharactersInDosageField(string)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTextField {
            dosageTextField.becomeFirstResponder()
        } else if textField == dosageTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}
