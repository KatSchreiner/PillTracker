//
//  DeleteAlertViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 11.05.2025.
//

import UIKit

class DeleteAlertViewController: UIViewController {
    var titleText: String?
    var tableView: UITableView?
    
    var onDeleteSingleDose: (() -> Void)?
    var onDeleteFutureDoses: (() -> Void)?
    var onCancel: (() -> Void)?

    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        titleLabel.textAlignment = .center
        return titleLabel
    }()

    private lazy var deleteSingleDoseButton: UIButton = {
        let deleteSingleDoseButton = UIButton(type: .custom)
        deleteSingleDoseButton.setTitle("Удалить эту дозу", for: .normal)
        deleteSingleDoseButton.setTitleColor(.dGray, for: .normal)
        deleteSingleDoseButton.backgroundColor = .lGray
        deleteSingleDoseButton.layer.cornerRadius = 8
        deleteSingleDoseButton.addTarget(self, action: #selector(deleteSingleDoseTapped), for: .touchUpInside)
        deleteSingleDoseButton.translatesAutoresizingMaskIntoConstraints = false
        return deleteSingleDoseButton
    }()
    
    private lazy var deleteFutureDosesButton: UIButton = {
        let deleteFutureDosesButton = UIButton(type: .custom)
        deleteFutureDosesButton.setTitle("Удалить все дозы", for: .normal)
        deleteFutureDosesButton.setTitleColor(.dGray, for: .normal)
        deleteFutureDosesButton.backgroundColor = .lGray
        deleteFutureDosesButton.layer.cornerRadius = 8
        deleteFutureDosesButton.addTarget(self, action: #selector(deleteFutureDosesTapped), for: .touchUpInside)
        deleteFutureDosesButton.translatesAutoresizingMaskIntoConstraints = false
        return deleteFutureDosesButton
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitle("Отмена", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.backgroundColor = .lBlue
        cancelButton.layer.cornerRadius = 8
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        return cancelButton
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, deleteSingleDoseButton, deleteFutureDosesButton, cancelButton])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @objc private func deleteSingleDoseTapped() {
        deleteSingleDoseButton.animatePress()
        
        onDeleteSingleDose?()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func deleteFutureDosesTapped() {
        deleteFutureDosesButton.animatePress()
        
        onDeleteFutureDoses?()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancelTapped() {
        cancelButton.animatePress()
        
        onCancel?()
        dismiss(animated: true, completion: nil)
    }
    
    private func setupView() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        
        titleLabel.text = titleText

        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            
            deleteSingleDoseButton.heightAnchor.constraint(equalToConstant: 60),
            deleteFutureDosesButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
