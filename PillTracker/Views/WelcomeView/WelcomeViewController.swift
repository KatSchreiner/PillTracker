//
//  WelcomeViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 27.04.2025.
//

import UIKit

final class WelcomeViewController: UIViewController {
    // MARK: - Private Properties
    private let userStore = UserStore()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Как тебя зовут?"
        textField.textAlignment = Constants.centerTextAlignment
        textField.layer.cornerRadius = Constants.defaultRadius
        textField.delegate = self
        textField.returnKeyType = .done
        textField.autocapitalizationType = .words
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "nextButton"), for: .normal)
        button.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        button.accessibilityIdentifier = "nextButton"
        return button
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameTextField, nextButton])
        stackView.axis = .horizontal
        stackView.spacing = Constants.defaultPadding
        stackView.distribution = .fill
        return stackView
    }()
    
    private var messageLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .dGray
        label.textColor = .white
        label.textAlignment = Constants.centerTextAlignment
        label.layer.cornerRadius = Constants.defaultRadius
        label.clipsToBounds = true
        label.alpha = 0
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        checkExistingUser()
    }
    
    // MARK: - IB Actions
    @objc
    private func didTapNextButton() {
        processNextAction()
    }
    
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .lGray
        
        [horizontalStackView, messageLabel].forEach { view in
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraint()
    }
    
    private func addConstraint() {
        NSLayoutConstraint.activate([
            horizontalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            horizontalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            horizontalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            messageLabel.bottomAnchor.constraint(equalTo: horizontalStackView.topAnchor, constant: -20),
            messageLabel.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        nameTextField.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    private func processNextAction() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            showMessage("Пожалуйста, введите имя")
            return
        }
        userStore.saveUser (name: name)
        navigateToMyPillsView()
    }
    
    private func navigateToMyPillsView() {
        guard let user  = userStore.fetchUser () else {
            showMessage("Не удалось получить данные пользователя")
            return
        }
        
        let myPillsViewController = MyPillsViewController(userName: user.name)
        navigationController?.pushViewController(myPillsViewController, animated: true)
    }
    
    private func showMessage(_ message: String) {
        messageLabel.text = message
        messageLabel.alpha = 1
        
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.messageLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: Constants.animationDuration, delay: 1.0, options: [], animations: {
                self.messageLabel.alpha = 0
            }, completion: nil)
        }
    }
    
    private func checkExistingUser () {
        guard userStore.fetchUser () != nil else { return }
        navigateToMyPillsView()
    }
}

// MARK: - UITextFieldDelegate
extension WelcomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        processNextAction()
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let newImageName = textField.text?.isEmpty == false ? "nextButtonTap" : "nextButton"
        let newImage = UIImage(named: newImageName)
        
        UIView.transition(
            with: nextButton,
            duration: Constants.animationDuration,
            options: .transitionCrossDissolve,
            animations: {
                self.nextButton.setImage(newImage, for: .normal
                )
            }, completion: nil)
    }
}
