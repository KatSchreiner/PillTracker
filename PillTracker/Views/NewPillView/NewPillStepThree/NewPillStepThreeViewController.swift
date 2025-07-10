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
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        let everyDayButton = createPresetButton(title: "Каждый день", action: #selector(didTapEveryDayButton))
        let everyOtherDayButton = createPresetButton(title: "Через день", action: #selector(didTapEveryOtherDayButton))
        let everyTwoDaysButton = createPresetButton(title: "Через 2 дня", action: #selector(didTapEveryTwoDaysButton))
        let customOptionButton = createPresetButton(title: "Свой вариант", action: #selector(didTapCustomOptionButton))
        
        stackView.addArrangedSubview(everyDayButton)
        stackView.addArrangedSubview(everyOtherDayButton)
        stackView.addArrangedSubview(everyTwoDaysButton)
        stackView.addArrangedSubview(customOptionButton)
        
        return stackView
    }()


    private func createPresetButton(title: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.dGray, for: .normal)
        button.backgroundColor = .lGray
        button.layer.cornerRadius = 8
        button.isEnabled = true
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
    
    private var dayButtonStackViewHeightConstraint: NSLayoutConstraint!
    private var isDurationSet: Bool = false
    private var currentAlertController: UIAlertController?

    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.performWithoutAnimation {
            loadData()
            self.view.layoutIfNeeded()
        }
        if model.selectedPreset == "Свой вариант" && !model.selectedDays.isEmpty {
            showDayButtonStackView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - IB Actions
    @objc private func didTapEveryDayButton() {
        model.selectedDays = []
        resetDayButtons()
        
        model.selectedPreset = "Каждый день"
        
        var selectedDays = [Int]()
        var currentDate = model.startDate ?? Date()
        
        while currentDate <= (model.endDate ?? Date()) {
            let weekday = (Calendar.current.component(.weekday, from: currentDate) + 5) % 7 + 1
            selectedDays.append(weekday)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        model.selectedDays = selectedDays
        model.interval = 0
        
        print("Лекарство отображается каждый день: \(selectedDays)")
        
        updatePresetButtonStates(selectedButton: "Каждый день")
        hideDayButtonStackView()
        updateNextButtonStateStepThree()
    }
    
    @objc private func didTapEveryOtherDayButton() {
        model.selectedDays = []
        resetDayButtons()
        
        model.selectedPreset = "Через день"
        
        var selectedDays = [Int]()
        var currentDate = model.startDate ?? Date()
        
        while currentDate <= (model.endDate ?? Date()) {
            let weekday = (Calendar.current.component(.weekday, from: currentDate) + 5) % 7 + 1
            selectedDays.append(weekday)
            currentDate = Calendar.current.date(byAdding: .day, value: 2, to: currentDate)!
        }
        
        model.selectedDays = selectedDays
        model.interval = 1
        
        print("Лекарство отображается через 1 день: \(selectedDays)")

        updatePresetButtonStates(selectedButton: "Через день")
        hideDayButtonStackView()
        updateNextButtonStateStepThree()
    }

    @objc private func didTapEveryTwoDaysButton() {
        model.selectedDays = []
        resetDayButtons()
        
        model.selectedPreset = "Через 2 дня"
        
        var selectedDays = [Int]()
        var currentDate = model.startDate ?? Date()
        
        while currentDate <= (model.endDate ?? Date()) {
            let weekday = (Calendar.current.component(.weekday, from: currentDate) + 5) % 7 + 1
            selectedDays.append(weekday)
            currentDate = Calendar.current.date(byAdding: .day, value: 3, to: currentDate)!
        }
        model.selectedDays = selectedDays
        model.interval = 2
        
        print("Лекарство отображается через 2 дня: \(selectedDays)")

        updatePresetButtonStates(selectedButton: "Через 2 дня")
        hideDayButtonStackView()
        updateNextButtonStateStepThree()
    }

    @objc private func didTapCustomOptionButton() {
        model.selectedDays = []
        model.interval = nil
        resetDayButtons()
        model.selectedPreset = "Свой вариант"

        if dayButtonStackView.isHidden {
            showDayButtonStackView()
        } else {
            hideDayButtonStackView()
        }
        
        for button in presetButtonStackView.arrangedSubviews {
            if let presetButton = button as? UIButton {
                presetButton.backgroundColor = .lGray
                presetButton.setTitleColor(.dGray, for: .normal)
            }
        }
        
        updatePresetButtonStates(selectedButton: "Свой вариант")
    }
    
    @objc
    private func didTapDayButton(sender: UIButton) {
        let index = sender.tag + 1
        
        if let itemIndex = model.selectedDays.firstIndex(of: index) {
            model.selectedDays.remove(at: itemIndex)
            sender.backgroundColor = .lGray
            sender.setTitleColor(.dGray, for: .normal)
        } else {
            model.selectedDays.append(index)
            sender.backgroundColor = .dBlue
            sender.setTitleColor(.lGray, for: .normal)
        }
        
        model.interval = nil
        
        print("Лекарство отображается по выбранным дням: \(model.selectedDays)")
        
        updateNextButtonStateStepThree()
    }
    
    @objc private func startDateChanged(sender: UIDatePicker) {
        let localDate = startOfDayInLocalTimeZone(for: sender.date)
        model.startDate = localDate
        updateNextButtonStateStepThree()
        print("Дата начала лечения обновлена: \(formattedDateString(for: localDate))")
    }

    @objc private func endDateChanged(sender: UIDatePicker) {
        let localDate = startOfDayInLocalTimeZone(for: sender.date)
        model.endDate = localDate
        updateNextButtonStateStepThree()
        print("Дата окончания лечения обновлена: \(formattedDateString(for: localDate))")
    }
    
    @objc
    private func didToggleReminderSwitch(sender: UISwitch) {
        model.isReminderEnabled = sender.isOn
        
        updateNextButtonStateStepThree()
    }
    
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .white
        
        dayButtonStackView.isHidden = true
        dayButtonStackView.alpha = 0

        [repeatLabel, presetButtonStackView, dayButtonStackView, durationLabel, customDateRangeStackView, reminderStackView].forEach { view in
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraint()
    }
    
    private func addConstraint() {
        dayButtonStackViewHeightConstraint = dayButtonStackView.heightAnchor.constraint(equalToConstant: 0)
        dayButtonStackViewHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            
            durationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            durationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            customDateRangeStackView.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 20),
            customDateRangeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customDateRangeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            repeatLabel.topAnchor.constraint(equalTo: customDateRangeStackView.bottomAnchor, constant: 30),
            repeatLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            presetButtonStackView.topAnchor.constraint(equalTo: repeatLabel.bottomAnchor, constant: 20),
            presetButtonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            presetButtonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            dayButtonStackView.topAnchor.constraint(equalTo: presetButtonStackView.bottomAnchor, constant: 20),
            dayButtonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dayButtonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            reminderStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            reminderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func loadData() {
        for button in dayButtons {
            let index = button.tag + 1
            let isSelected = model.selectedDays.contains(index)
            button.backgroundColor = isSelected ? .dBlue : .lGray
            button.setTitleColor(isSelected ? .lGray : .dGray, for: .normal)
        }
        
        reminderSwitch.isOn = model.isReminderEnabled
        
        let currentDate = startOfDayInLocalTimeZone(for: Date())
        startDatePicker.date = model.startDate ?? currentDate
        endDatePicker.date = model.endDate ?? currentDate
        
        if let selectedPreset = model.selectedPreset {
            updatePresetButtonStates(selectedButton: selectedPreset)
            
            if selectedPreset == "Свой вариант" && !model.selectedDays.isEmpty {
                DispatchQueue.main.async {
                    self.dayButtonStackView.isHidden = false
                    self.dayButtonStackViewHeightConstraint.constant = 35
                    self.dayButtonStackView.alpha = 1
                    self.view.layoutIfNeeded()
                }
            }
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
    
    private func resetDayButtons() {
        for button in dayButtons {
            button.backgroundColor = .lGray
            button.setTitleColor(.dGray, for: .normal)
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
    
    private func weekdayNumber(from date: Date) -> Int {
        let calendar = Calendar.current
        return (calendar.component(.weekday, from: date) + 5) % 7 + 1
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
    
    private func showDayButtonStackView() {
        guard dayButtonStackView.isHidden else { return }
        self.view.layoutIfNeeded()
        
        dayButtonStackView.isHidden = false
        dayButtonStackViewHeightConstraint.constant = 35
        
        UIView.animate(withDuration: 0.3, animations: {
            self.dayButtonStackView.alpha = 1
            self.view.layoutIfNeeded()
        })
    }
    private func hideDayButtonStackView() {
        dayButtonStackViewHeightConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            self.dayButtonStackView.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.dayButtonStackView.isHidden = true
        })
    }
}
