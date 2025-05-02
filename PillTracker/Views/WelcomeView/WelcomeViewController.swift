//
//  WelcomeViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 27.04.2025.
//

import UIKit

class WelcomeViewController: UIViewController {
    // MARK: - Private Properties
    private let userStore = UserStore()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Как тебя зовут?"
        textField.textAlignment = .center
        textField.layer.cornerRadius = 10
        textField.delegate = self
        return textField
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "nextButton"), for: .normal)
        button.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameTextField, nextButton])
        stackView.axis = .horizontal
        stackView.spacing = 20
        return stackView
    }()
    
    private var messageLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .dGray
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.alpha = 0
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
        guard let name = nameTextField.text, !name.isEmpty else {
            showMessage("Пожалуйста, введите имя")
            return
        }
        userStore.saveUser (name: name)
        navigateToMyPillsView()
    }
    
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .lGray
        
        [stackView, messageLabel].forEach { view in
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            messageLabel.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -20),
            messageLabel.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        nameTextField.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    private func navigateToMyPillsView() {
        let myPillsViewController = MyPillsViewController()
        navigationController?.pushViewController(myPillsViewController, animated: true)
    }
    
    private func showMessage(_ message: String) {
        messageLabel.text = message
        messageLabel.alpha = 1
        
        UIView.animate(withDuration: 0.3, animations: {
            self.messageLabel.alpha = 1
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIView.animate(withDuration: 0.5) {
                    self.messageLabel.alpha = 0
                }
            }
        }
    }
    
    private func checkExistingUser () {
        if let existingUser  = userStore.fetchUser () {
            navigateToMyPillsView()
        }
    }
}

// MARK: - UITextFieldDelegate
extension WelcomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        navigateToMyPillsView()
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let newImageName = textField.text?.isEmpty == false ? "nextButtonTap" : "nextButton"
        let newImage = UIImage(named: newImageName)
        
        UIView.transition(with: nextButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.nextButton.setImage(newImage, for: .normal
            )
        }, completion: nil)
    }
}
