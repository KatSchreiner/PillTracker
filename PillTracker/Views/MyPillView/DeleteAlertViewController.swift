//
//  DeleteAlertViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 11.05.2025.
//

import UIKit

final class DeleteAlertViewController: UIViewController {
    //MARK: - Public properties
    var titleText: String?
    
    //MARK: - Private Properties
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = Constants.titleFontSize
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    private lazy var deleteSingleDoseButton = CustomButton.makeButton(
        title: "Удалить одну дозу",
        titleColor: .dGray,
        backgroundColor: .lGray,
        cornerRadius: Constants.defaultRadius,
        target: self,
        action: #selector(deleteSingleDoseTapped)
    )
    
    private lazy var deleteFutureDosesButton = CustomButton.makeButton(
        title: "Удалить все будущие дозы",
        titleColor: .dGray,
        backgroundColor: .lGray,
        cornerRadius: Constants.defaultRadius,
        target: self,
        action: #selector(deleteFutureDosesTapped)
    )
    
    private lazy var cancelButton = CustomButton.makeButton(
        title: "Отмена",
        titleColor: .white,
        backgroundColor: .lBlue,
        cornerRadius: Constants.defaultRadius,
        target: self,
        action: #selector(cancelTapped)
    )
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, deleteSingleDoseButton, deleteFutureDosesButton, cancelButton])
        stackView.axis = .vertical
        stackView.spacing = Constants.smallPadding
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    //MARK: - Callbacks
    var onDeleteSingleDose: (() -> Void)?
    var onDeleteFutureDoses: (() -> Void)?
    var onCancel: (() -> Void)?
    
    //MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    //MARK: - IB Actions
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
    
    //MARK: Private Methods
    private func setupView() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        
        titleLabel.text = titleText
        
        view.addSubview(stackView)
        addConstraints()
    }
    
    private func addConstraints() {
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
