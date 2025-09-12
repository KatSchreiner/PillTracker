//
//  StepViewControllerBase.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 04.09.2025.
//

import UIKit

final class BaseStepViewController: UIViewController {
    weak var parentStepHandler: AddNewPillViewController?
    
    // MARK: - UI Creation Methods
    func createLabel(text: String, fontSize: CGFloat = 18, textColor: UIColor = .dGray) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.textColor = textColor
        label.text = text
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func createButton(title: String? = nil, image: UIImage? = nil, target: Any?, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        if let title = title {
            button.setTitle(title, for: .normal)
            button.setTitleColor(.dGray, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        }
        if let image = image {
            button.setImage(image, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
        }
        button.backgroundColor = .lGray
        button.layer.cornerRadius = 8
        button.addTarget(target, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    func createTextField(placeholder: String? = nil, keyboardType: UIKeyboardType = .default, delegate: UITextFieldDelegate? = nil) -> UITextField {
        let textField = UITextField()
        textField.layer.cornerRadius = 8
        textField.backgroundColor = .white
        textField.textColor = .dGray
        textField.textAlignment = .left
        textField.keyboardType = keyboardType
        textField.delegate = delegate
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
        textField.translatesAutoresizingMaskIntoConstraints = false
        if let placeholder = placeholder {
            textField.placeholder = placeholder
        }
        return textField
    }
    
    func updateButtonState(isEnabled: Bool, isNextButton: Bool) {
        DispatchQueue.main.async { [weak self] in
            if let parent = self?.parentStepHandler ?? self?.parent as? AddNewPillViewController {
                let button = isNextButton ? parent.nextButton : parent.doneButton
                button.isEnabled = isEnabled
                button.alpha = isEnabled ? 1.0 : 0.5
                
                UIView.animate(withDuration: 0.3) {
                    button.layoutIfNeeded()
                }
            }
        }
    }
}
