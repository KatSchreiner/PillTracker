//
//  ViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 06.04.2025.
//

import UIKit

class MyPillsViewController: UIViewController {
    // MARK: - Private Properties

    lazy var bottomBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .lGray
        return view
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    lazy var dateLabelBackground: UIView = {
        let dateLabelBackground = UIView()
        dateLabelBackground.backgroundColor = .clear
        return dateLabelBackground
    }()
    
    lazy var addPillButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "plus")
        button.setImage(image, for: .normal)
        button.backgroundColor = .lBlue
        button.tintColor = .white
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(didTapAddPillButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - IB Actions
    @objc
    private func didTapAddPillButton() {
//        let addNewPill = AddNewPillViewController()
//        navigationController?.pushViewController(addNewPill, animated: true)
    }

    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .systemBackground
                
        [dateLabelBackground, dateLabel, addPillButton, bottomBorderView].forEach { view in
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        dateLabel.text = "06 апреля 2025"
        
        addConstraint()
    }
    
    private func addConstraint() {
        NSLayoutConstraint.activate([
            dateLabelBackground.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dateLabelBackground.heightAnchor.constraint(equalToConstant: 30),
            dateLabelBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dateLabelBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            dateLabel.bottomAnchor.constraint(equalTo: dateLabelBackground.bottomAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: dateLabelBackground.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: dateLabelBackground.trailingAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: dateLabelBackground.centerYAnchor),
            
            bottomBorderView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor),
            bottomBorderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBorderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBorderView.heightAnchor.constraint(equalToConstant: 2),
            
            addPillButton.widthAnchor.constraint(equalToConstant: 70),
            addPillButton.heightAnchor.constraint(equalToConstant: 70),
            addPillButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addPillButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter.string(from: date)
    }

}
