//
//  NewPillStepOneViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 07.04.2025.
//

import UIKit

class NewPillStepOneViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Public Properties
    static let stepOne = "NewPillStepOneCell"
    
    var pillStepOneModel: PillStepOneModel?
    
    var selectedUnit: String?
    
    lazy var titleTextField: UITextField = createTextField()
    lazy var dosageTextField: UITextField = createTextField()
    
    lazy var unitButton: UIButton = {
        let unitButton = UIButton(type: .system)
        unitButton.setTitle("Выберите единицу", for: .normal)
        unitButton.setTitleColor(.dGray, for: .normal)
        unitButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        unitButton.backgroundColor = .lGray
        unitButton.layer.cornerRadius = 8
        unitButton.addTarget(self, action: #selector(didTapUnitButton), for: .touchUpInside)
        return unitButton
    }()
    
    lazy var formTypesButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.setImage(UIImage(named: "tablet"), for: .normal)
        button.addTarget(self, action: #selector(didTapFormTypesButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Private Properties
    private lazy var titleLabel: UILabel = createLabel(text: "Название", textColor: .black, fontSize: 20)
    private lazy var dosageLabel: UILabel = createLabel(text: "Дозировка", textColor: .black, fontSize: 20)
        
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - IB Actions
    @objc
    private func didTapFormTypesButton() {
        let iconSelectionVC = IconSelectionViewController()

        iconSelectionVC.selectedIcon = { [weak self] selectedIcon in
            self?.formTypesButton.setImage(selectedIcon, for: .normal)
            self?.pillStepOneModel?.selectedIcon = selectedIcon
        }
        
        iconSelectionVC.presentAsBottomSheet(on: self)
    }
    
    @objc
    private func didTapUnitButton() {
        let unitSelectionView = UnitSelectionViewController()

        unitSelectionView.selectedUnit = { [weak self] selectedUnit in
            self?.selectedUnit = selectedUnit
            self?.pillStepOneModel?.selectedUnit = selectedUnit
            self?.unitButton.setTitle(selectedUnit, for: .normal)
        }
        
        unitSelectionView.presentAsBottomSheet(on: self)
    }
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        updateNextButtonState()
    }
    
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .white
        
        formTypesButton.setImage(UIImage(named: "tablet"), for: .normal)
        
        loadData()
        
        dosageTextField.keyboardType = .decimalPad
        
        [formTypesButton, titleLabel, titleTextField, dosageLabel, dosageTextField, unitButton].forEach { view in
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraint()
    }
    
    private func addConstraint() {
        NSLayoutConstraint.activate([
            formTypesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            formTypesButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),

            titleLabel.topAnchor.constraint(equalTo: formTypesButton.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),

            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleTextField.heightAnchor.constraint(equalToConstant: 60),

            dosageLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            dosageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),

            dosageTextField.topAnchor.constraint(equalTo: dosageLabel.bottomAnchor, constant: 10),
            dosageTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dosageTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dosageTextField.heightAnchor.constraint(equalToConstant: 60),
            
            unitButton.topAnchor.constraint(equalTo: dosageTextField.bottomAnchor, constant: 20),
            unitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            unitButton.heightAnchor.constraint(equalToConstant: 60),
            unitButton.widthAnchor.constraint(equalToConstant: 200)
        ])
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
        textField.backgroundColor = .lGray
        textField.textColor = .dGray
        textField.textAlignment = .left
        textField.delegate = self
        textField.isUserInteractionEnabled = true
        
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 60))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 60))
        textField.rightViewMode = .always
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return textField
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
        }
    }
    
    private func updateNextButtonState() {
        let isTitleFilled = !(titleTextField.text?.isEmpty ?? true)
        let isDosageFilled = !(dosageTextField.text?.isEmpty ?? true)
        let isEnabled = isTitleFilled && isDosageFilled
        
        if let addNewPillVC = parent as? AddNewPillViewController {
            addNewPillVC.nextButton.isEnabled = isEnabled
            addNewPillVC.nextButton.alpha = isEnabled ? 1.0 : 0.5
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == dosageTextField {
            let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        return true
    }
}
