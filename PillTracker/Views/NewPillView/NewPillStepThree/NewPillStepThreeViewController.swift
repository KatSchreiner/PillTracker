//
//  NewPillStepThreeViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 07.04.2025.
//

import UIKit

class NewPillStepThreeViewController: UIViewController {
    static var stepThree = "NewPillStepThreeCell"
    
    var model = PillStepThreeModel()
    
    private lazy var repeatLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .dGray
        label.text = "Повторить"
        label.textAlignment = .left
        return label
    }()
    
    private lazy var dayButtons: [UIButton] = []
    private let daysOfWeek = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    private lazy var dayButtonStackView: UIStackView = {
        let dayButtonStackView = UIStackView()
        dayButtonStackView.axis = .horizontal
        dayButtonStackView.distribution = .fillEqually
        dayButtonStackView.spacing = 10
        
        for (index, day) in daysOfWeek.enumerated() {
            let button = UIButton()
            button.layer.cornerRadius = 8
            button.backgroundColor = .lGray
            button.setTitle(day, for: .normal)
            button.setTitleColor(.gray, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            button.tag = index
            button.addTarget(self, action: #selector(didTapDayButton), for: .touchUpInside)
            dayButtons.append(button)
            dayButtonStackView.addArrangedSubview(button)
        }
        
        return dayButtonStackView
    }()
    
    private lazy var reminderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        label.textColor = .dGray
        label.text = "Напомнить?"
        label.textAlignment = .left
        return label
    }()
    
    private lazy var reminderSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = false
        switchControl.addTarget(self, action: #selector(didToggleReminderSwitch), for: .valueChanged)
        return switchControl
    }()
    
    private lazy var reminderStackView: UIStackView = {
        let reminderStackView = UIStackView(arrangedSubviews: [reminderLabel, reminderSwitch])
        reminderStackView.axis = .horizontal
        reminderStackView.spacing = 20
        return reminderStackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadData()
    }
    
    @objc
    private func didTapDayButton(sender: UIButton) {
        let index = sender.tag + 1
        if model.selectedDays.contains(index) {
            model.selectedDays.remove(index)
            sender.backgroundColor = .lGray
            sender.setTitleColor(.gray, for: .normal)
        } else {
            model.selectedDays.insert(index)
            sender.backgroundColor = .dBlue
            sender.setTitleColor(.lGray, for: .normal)
        }
    }
    
    @objc
    private func didToggleReminderSwitch(sender: UISwitch) {
        model.isReminderEnabled = sender.isOn
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        [repeatLabel, dayButtonStackView, reminderStackView].forEach { view in
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraint()
    }
    
    private func addConstraint() {
        NSLayoutConstraint.activate([
            repeatLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            repeatLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            dayButtonStackView.topAnchor.constraint(equalTo: repeatLabel.bottomAnchor, constant: 20),
            dayButtonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dayButtonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dayButtonStackView.heightAnchor.constraint(equalToConstant: 40),
            
            reminderStackView.topAnchor.constraint(equalTo: dayButtonStackView.bottomAnchor, constant: 30),
            reminderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func loadData() {
        for button in dayButtons {
            let index = button.tag
            if model.selectedDays.contains(index) {
                button.backgroundColor = .dBlue
                button.setTitleColor(.lGray, for: .normal)
            } else {
                button.backgroundColor = .lGray
                button.setTitleColor(.dGray, for: .normal)
            }
        }
        
        reminderSwitch.isOn = model.isReminderEnabled
    }
}
