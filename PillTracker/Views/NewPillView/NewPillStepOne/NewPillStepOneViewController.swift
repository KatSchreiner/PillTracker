//
//  NewPillStepOneViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 07.04.2025.
//

import UIKit

class NewPillStepOneViewController: UIViewController {
    
    // MARK: - Public Properties
    static let stepOne = "NewPillStepOneCell"
    
    var pillStepOneModel: PillStepOneModel?
    
    var selectedUnit: String?
    var dosage: Double = 0 {
        didSet {
            updateUnitButtonTitle()
        }
    }
    
    lazy var titleTextField: UITextField = createTextField()
    lazy var dosageTextField: UITextField = createTextField()
    
    lazy var unitButton: UIButton = {
        let unitButton = UIButton(type: .custom)
        unitButton.setTitle("Выберите единицу", for: .normal)
        unitButton.setTitleColor(.dGray, for: .normal)
        unitButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        unitButton.backgroundColor = .lGray
        unitButton.layer.cornerRadius = 8
        unitButton.addTarget(self, action: #selector(didTapUnitButton), for: .touchUpInside)
        return unitButton
    }()
    
    lazy var formTypesButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(named: "photoCamera"), for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(didTapFormTypesButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Private Properties
    private lazy var titleLabel: UILabel = createLabel(text: "Название", textColor: .black, fontSize: 18)
    private lazy var dosageLabel: UILabel = createLabel(text: "Дозировка", textColor: .black, fontSize: 18)
        
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
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - IB Actions
    @objc
    private func didTapFormTypesButton() {
        formTypesButton.animatePress()
        
        let iconSelectionView = IconSelectionViewController()

        iconSelectionView.selectedIcon = { [weak self] selectedIcon in
            self?.animateIconChange(to: selectedIcon)
            self?.pillStepOneModel?.selectedIcon = selectedIcon
            self?.updateNextButtonStateStepOne()
        }
        
        iconSelectionView.presentAsBottomSheet(on: self)
    }
    
    @objc
    private func didTapUnitButton() {
        unitButton.animatePress()
        
        let unitSelectionView = UnitSelectionViewController()

        unitSelectionView.dosage = dosage
        unitSelectionView.selectedUnit = { [weak self] selectedUnit in
            self?.selectedUnit = selectedUnit
            self?.pillStepOneModel?.selectedUnit = selectedUnit
            self?.updateUnitButtonTitle()
            self?.updateNextButtonStateStepOne()
        }
        
        unitSelectionView.presentAsBottomSheet(on: self)
    }
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        if let dosageText = textField.text, let dosageValue = Double(dosageText) {
            dosage = dosageValue
        } else {
            dosage = 0
        }
        updateNextButtonStateStepOne()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func createLabel(text: String, textColor: UIColor, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.text = text
        label.textColor = textColor
        label.textAlignment = .left
        label.textColor = .dGray
        return label
    }
    
    private func createTextField() -> UITextField {
        let textField = UITextField()
        textField.layer.cornerRadius = 8
        textField.backgroundColor = .white
        textField.textColor = .dGray
        textField.textAlignment = .left
        textField.isUserInteractionEnabled = true
        
        textField.layer.shadowColor = UIColor.lGray.cgColor
        textField.layer.shadowOpacity = 0.1
        textField.layer.shadowOffset = CGSize(width: 0, height: 1)
        textField.layer.shadowRadius = 6
        
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lGray.cgColor
        
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 60))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 60))
        textField.rightViewMode = .always

        textField.delegate = self
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }
    
    private func setupTextFields() {
        titleTextField.returnKeyType = .next
        dosageTextField.returnKeyType = .done
        dosageTextField.keyboardType = .numberPad
    }
    
    private func loadData() {
        titleTextField.text = pillStepOneModel?.title
        
        if let dosage = pillStepOneModel?.dosage {
            dosageTextField.text = String(format: "%.1f", dosage)
        } else {
            dosageTextField.text = nil
        }
        
        if let selectedIcon = pillStepOneModel?.selectedIcon {
            formTypesButton.setImage(selectedIcon, for: .normal)
        }
        
        if let selectedUnit = pillStepOneModel?.selectedUnit {
            self.selectedUnit = selectedUnit
            unitButton.setTitle(selectedUnit, for: .normal)
        }
    }
    
    func updateNextButtonStateStepOne() {
        pillStepOneModel?.title = titleTextField.text
        if let dosageText = dosageTextField.text, let dosageValue = Double(dosageText) {
            pillStepOneModel?.dosage = dosageValue
        } else {
            pillStepOneModel?.dosage = nil
        }
        
        let isEnabled = pillStepOneModel?.isValid() ?? false
        
        if let addNewPillView = parent as? AddNewPillViewController {
            addNewPillView.nextButton.isEnabled = isEnabled
            addNewPillView.nextButton.alpha = isEnabled ? 1.0 : 0.5
        }
    }
    
    private func animateIconChange(to newIcon: UIImage?) {
        let currentImage = formTypesButton.image(for: .normal)
        
        formTypesButton.setImage(newIcon, for: .normal)
        
        formTypesButton.alpha = 0.0
        
        UIView.animate(withDuration: 0.3, animations: {
            self.formTypesButton.alpha = 1.0
        }) { _ in
        }
    }
    
    private func updateUnitButtonTitle() {
        guard let selectedUnit = selectedUnit else { return }
        let unitTitle = getUnitTitle(for: dosage, unit: selectedUnit)
        unitButton.setTitle(unitTitle, for: .normal)
    }
    
    private func getUnitTitle(for dosage: Double, unit: String) -> String {
        return String.getUnitTitle(for: dosage, unit: unit)
    }
}

// MARK: UITextFieldDelegate
extension NewPillStepOneViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == dosageTextField {
            let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
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


