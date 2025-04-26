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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .lGray
        
        [nameTextField].forEach { view in
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: 60),
            nameTextField.widthAnchor.constraint(equalToConstant: 250),
        ])
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
}
