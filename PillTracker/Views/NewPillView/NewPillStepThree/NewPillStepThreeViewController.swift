//
//  NewPillStepThreeViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 07.04.2025.
//

import UIKit

class NewPillStepThreeViewController: UIViewController {
    // MARK: - Public Properties
    static var stepThree = "NewPillStepThreeCell"
    
    var model = PillStepThreeModel()
    
    // MARK: - Private Properties
    private lazy var repeatLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
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
            button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            button.tag = index
            button.addTarget(self, action: #selector(didTapDayButton), for: .touchUpInside)
            dayButtons.append(button)
            dayButtonStackView.addArrangedSubview(button)
        }
        
        return dayButtonStackView
    }()
    
    private lazy var durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .dGray
        label.text = "Продолжительность лечения"
        label.textAlignment = .left
        return label
    }()
    
    private lazy var durationSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["1 неделя", "2 недели", "1 месяц", "Другое"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(didChangeDuration), for: .valueChanged)
        return segmentedControl
    }()
    
    private lazy var startDateLabel: UILabel = {
        let label = UILabel()
        label.text = "Начало лечения:"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var startDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.tintColor = .dBlue
        return datePicker
    }()
    
    private lazy var endDateLabel: UILabel = {
        let label = UILabel()
        label.text = "Окончание лечения:"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var endDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.tintColor = .dBlue
        return datePicker
    }()
    
    private lazy var startDateStackView: UIStackView = {
        let startDateStackView = UIStackView(arrangedSubviews: [startDateLabel, startDatePicker])
        startDateStackView.axis = .horizontal
        startDateStackView.spacing = 10
        return startDateStackView
    }()
    
    private lazy var endDateStackView: UIStackView = {
        let endDateStackView = UIStackView(arrangedSubviews: [endDateLabel, endDatePicker])
        endDateStackView.axis = .horizontal
        endDateStackView.spacing = 10
        return endDateStackView
    }()
    
    private lazy var customDateRangeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [startDateStackView, endDateStackView])
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var reminderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
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
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    // MARK: - IB Actions
    @objc
    private func didTapDayButton(sender: UIButton) {
        let index = sender.tag + 1
        if model.selectedDays.contains(index) {
            model.selectedDays.remove(index)
            sender.backgroundColor = .lGray
            sender.setTitleColor(.dGray, for: .normal)
        } else {
            model.selectedDays.insert(index)
            sender.backgroundColor = .dBlue
            sender.setTitleColor(.lGray, for: .normal)
        }
        
        updateNextButtonStateStepThree()
    }
    
    @objc
    private func didChangeDuration(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 3 {
            if customDateRangeStackView.superview == nil {
                
                self.view.addSubview(customDateRangeStackView)
                customDateRangeStackView.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    customDateRangeStackView.topAnchor.constraint(equalTo: durationSegmentedControl.bottomAnchor, constant: 20),
                    customDateRangeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    customDateRangeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                ])
            }
        } else {
            customDateRangeStackView.removeFromSuperview()
        }
    }
    
    @objc
    private func didToggleReminderSwitch(sender: UISwitch) {
        model.isReminderEnabled = sender.isOn
        
        updateNextButtonStateStepThree()
    }
    
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .white
        
        [repeatLabel, dayButtonStackView, durationLabel, durationSegmentedControl,  reminderStackView].forEach { view in
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
            dayButtonStackView.heightAnchor.constraint(equalToConstant: 35),
            
            
            durationLabel.topAnchor.constraint(equalTo: dayButtonStackView.bottomAnchor, constant: 30),
            durationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            durationSegmentedControl.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 10),
            durationSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            durationSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            durationSegmentedControl.heightAnchor.constraint(equalToConstant: 35),
            
            reminderStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            reminderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func loadData() {
        for button in dayButtons {
            let index = button.tag + 1
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
    
    func updateNextButtonStateStepThree() {
        let isEnabled = model.isValid()
        
        if let addNewPillView = parent as? AddNewPillViewController {
            addNewPillView.doneButton.isEnabled = isEnabled
            addNewPillView.doneButton.alpha = isEnabled ? 1.0 : 0.5
            print("Done button state updated: \(isEnabled)")
        }
    }
}
