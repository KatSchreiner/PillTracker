//
//  WelcomeViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 27.04.2025.
//

import UIKit

class WelcomeViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @objc
    private func didTapNextButton() {
        if let name = nameTextField.text, !name.isEmpty {
            let myPillsView = MyPillsViewController()
            myPillsView.userName = name
            navigationController?.pushViewController(myPillsView, animated: true)
        }
    }
    
    private func setupView() {
        view.backgroundColor = .lGray
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        nameTextField.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
}

extension WelcomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let name = textField.text, !name.isEmpty {
            let myPillsViewController = MyPillsViewController()
            myPillsViewController.userName = name
            navigationController?.pushViewController(myPillsViewController, animated: true)
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let newImageName = textField.text?.isEmpty == false ? "nextButtonTap" : "nextButton"
        let newImage = UIImage(named: newImageName)
        
        UIView.transition(with: nextButton, duration: 1.0, options: .transitionCrossDissolve, animations: {
            self.nextButton.setImage(newImage, for: .normal
            )
        }, completion: nil)
    }
}
