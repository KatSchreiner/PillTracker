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
    
    private lazy var presetButtonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        let everyDayButton = createPresetButton(title: "Каждый день", action: #selector(didTapEveryDayButton))
        let everyOtherDayButton = createPresetButton(title: "Через день", action: #selector(didTapEveryOtherDayButton))
        let everyTwoDaysButton = createPresetButton(title: "Через 2 дня", action: #selector(didTapEveryTwoDaysButton))
        
        stackView.addArrangedSubview(everyDayButton)
        stackView.addArrangedSubview(everyOtherDayButton)
        stackView.addArrangedSubview(everyTwoDaysButton)
        
        return stackView
    }()

    private func createPresetButton(title: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.dGray, for: .normal)
        button.backgroundColor = .lGray
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    
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
        datePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
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
        datePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)
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
    @objc private func didTapEveryDayButton() {
        model.selectedDays = Set(1...7)
        updatePresetButtonStates(selectedButton: "Каждый день")
        updateNextButtonStateStepThree()
    }

    @objc private func didTapEveryOtherDayButton() {
        model.selectedDays = [1, 3, 5, 7]
        updatePresetButtonStates(selectedButton: "Через день")
        updateNextButtonStateStepThree()
    }

    @objc private func didTapEveryTwoDaysButton() {
        model.selectedDays = [1, 4, 7]
        updatePresetButtonStates(selectedButton: "Через 2 дня")
        updateNextButtonStateStepThree()
    }

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
    
    @objc private func startDateChanged(sender: UIDatePicker) {
        let localDate = startOfDayInLocalTimeZone(for: sender.date)
        model.startDate = localDate
        updateNextButtonStateStepThree()
        print("Start date updated: \(formattedDateString(for: localDate))")
    }

    @objc private func endDateChanged(sender: UIDatePicker) {
        let localDate = startOfDayInLocalTimeZone(for: sender.date)
        model.endDate = localDate
        updateNextButtonStateStepThree()
        print("End date updated: \(formattedDateString(for: localDate))")
    }
    
    @objc
    private func didToggleReminderSwitch(sender: UISwitch) {
        model.isReminderEnabled = sender.isOn
        
        updateNextButtonStateStepThree()
    }
    
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .white
        
        [repeatLabel, presetButtonStackView, dayButtonStackView, durationLabel, customDateRangeStackView,   reminderStackView].forEach { view in
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraint()
    }
    
    private func addConstraint() {
        NSLayoutConstraint.activate([
            repeatLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            repeatLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            presetButtonStackView.topAnchor.constraint(equalTo: repeatLabel.bottomAnchor, constant: 20),
            presetButtonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            presetButtonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            presetButtonStackView.heightAnchor.constraint(equalToConstant: 35),
            
            dayButtonStackView.topAnchor.constraint(equalTo: presetButtonStackView.bottomAnchor, constant: 20),
            dayButtonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dayButtonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dayButtonStackView.heightAnchor.constraint(equalToConstant: 35),
            
            
            durationLabel.topAnchor.constraint(equalTo: dayButtonStackView.bottomAnchor, constant: 30),
            durationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            customDateRangeStackView.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 10),
            customDateRangeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customDateRangeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
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

        if model.startDate == nil {
            model.startDate = startOfDayInLocalTimeZone(for: Date())
        }
        startDatePicker.date = model.startDate ?? startOfDayInLocalTimeZone(for: Date())
        print("Loaded Start Date: \(formattedDateString(for: startDatePicker.date))")

        if let endDate = model.endDate {
            endDatePicker.date = startOfDayInLocalTimeZone(for: endDate)
            print("Loaded End Date: \(formattedDateString(for: endDatePicker.date))")
        } else {
            endDatePicker.date = startOfDayInLocalTimeZone(for: Date())
            print("Loaded Default End Date: \(formattedDateString(for: endDatePicker.date))")
        }
    }

    private func updateDayButtonStates() {
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
    }
    
    private func updatePresetButtonStates(selectedButton: String) {
        for button in presetButtonStackView.arrangedSubviews {
            if let presetButton = button as? UIButton {
                if presetButton.title(for: .normal) == selectedButton {
                    presetButton.backgroundColor = .dBlue
                    presetButton.setTitleColor(.white, for: .normal)
                } else {
                    presetButton.backgroundColor = .lGray
                    presetButton.setTitleColor(.dGray, for: .normal)
                }
            }
        }
    }

    func startOfDayInLocalTimeZone(for date: Date) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar.startOfDay(for: date)
    }
    
    func formattedStartDate() -> String {
        guard let startDate = model.startDate else { return "Не указано" }
        return formattedDateString(for: startDate)
    }
    func formattedEndDate() -> String {
        guard let endDate = model.endDate else { return "Не указано" }
        return formattedDateString(for: endDate)
    }
    
    private func formattedDateString(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date)
    }
    
    func updateNextButtonStateStepThree() {
        let isEnabled = model.isValid()
        
        if let addNewPillView = parent as? AddNewPillViewController {
            addNewPillView.doneButton.isEnabled = isEnabled
            addNewPillView.doneButton.alpha = isEnabled ? 1.0 : 0.5
        }
    }
}
