//
//  NewPillStepThreeViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 07.04.2025.
//

import UIKit

final class NewPillStepThreeViewController: BaseStepViewController {
    // MARK: - Public Properties
    let viewModel = NewPillStepThreeViewModel()
    
    // MARK: - Private Properties
    private lazy var repeatLabel = createLabel(text: "Повторить")
    
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
    
    private lazy var dayButtonStackView: UIStackView = {
        let dayButtonStackView = UIStackView()
        dayButtonStackView.axis = .horizontal
        dayButtonStackView.distribution = .fillEqually
        dayButtonStackView.spacing = 10
        
        for (index, day) in viewModel.daysOfWeek.enumerated() {
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
        setupBindings()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.performWithoutAnimation {
            loadData()
            self.view.layoutIfNeeded()
        }
        if viewModel.selectedPreset == "Свой вариант" && !viewModel.selectedDays.isEmpty {
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
        viewModel.selectedDays = []
        resetDayButtons()
        
        viewModel.selectedPreset = "Каждый день"
        viewModel.selectedDays = viewModel.calculateSelectedDaysForPreset("Каждый день")
        viewModel.interval = 0
        
        updatePresetButtonStates(selectedButton: "Каждый день")
        hideDayButtonStackView()
        viewModel.checkValidity()
    }
    
    @objc private func didTapEveryOtherDayButton() {
        viewModel.selectedDays = []
        resetDayButtons()
        
        viewModel.selectedPreset = "Через день"
        viewModel.selectedDays = viewModel.calculateSelectedDaysForPreset("Через день")
        viewModel.interval = 1
        
        updatePresetButtonStates(selectedButton: "Через день")
        hideDayButtonStackView()
        viewModel.checkValidity()
    }
    
    @objc private func didTapEveryTwoDaysButton() {
        viewModel.selectedDays = []
        resetDayButtons()
        
        viewModel.selectedPreset = "Через 2 дня"
        viewModel.selectedDays = viewModel.calculateSelectedDaysForPreset("Через 2 дня")
        viewModel.interval = 2
        
        updatePresetButtonStates(selectedButton: "Через 2 дня")
        hideDayButtonStackView()
        viewModel.checkValidity()
    }
    
    @objc private func didTapCustomOptionButton() {
        viewModel.selectedDays = []
        viewModel.interval = nil
        resetDayButtons()
        viewModel.selectedPreset = "Свой вариант"
        
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
        
        if let itemIndex = viewModel.selectedDays.firstIndex(of: index) {
            viewModel.selectedDays.remove(at: itemIndex)
            sender.backgroundColor = .lGray
            sender.setTitleColor(.dGray, for: .normal)
        } else {
            viewModel.selectedDays.append(index)
            sender.backgroundColor = .dBlue
            sender.setTitleColor(.lGray, for: .normal)
        }
        
        viewModel.interval = nil
        viewModel.checkValidity()
    }
    
    @objc private func startDateChanged(sender: UIDatePicker) {
        viewModel.startDate = viewModel.startOfDayInLocalTimeZone(for: sender.date)
        viewModel.checkValidity()
    }
    
    @objc private func endDateChanged(sender: UIDatePicker) {
        viewModel.endDate = viewModel.startOfDayInLocalTimeZone(for: sender.date)
        viewModel.checkValidity()
    }
    
    @objc
    private func didToggleReminderSwitch(sender: UISwitch) {
        viewModel.isReminderEnabled = sender.isOn
        
        if sender.isOn {
            MedicationNotificationManager.shared.requestAuthorization { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.showReminderActivatedAlert()
                    } else {
                        self?.showNotificationPermissionAlert()
                        sender.isOn = false
                        self?.viewModel.isReminderEnabled = false
                    }
                }
            }
        }
        
        viewModel.checkValidity()
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
    
    private func setupBindings() {
        viewModel.onValidationChange = { [weak self] isValid in
            self?.updateButtonState(isEnabled: isValid, isNextButton: false)
        }
        
        viewModel.onSelectedPresetChanged = { [weak self] preset in
            DispatchQueue.main.async {
                self?.updatePresetButtonStates(selectedButton: preset ?? "")
                if preset == "Свой вариант" && !(self?.viewModel.selectedDays.isEmpty ?? true) {
                    self?.showDayButtonStackView()
                } else {
                    self?.hideDayButtonStackView()
                }
            }
        }
        
        viewModel.onSelectedDaysChanged = { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateDayButtonStates()
            }
        }
        
        viewModel.onStartDateChanged = { [weak self] date in
            DispatchQueue.main.async {
                if let date = date {
                    self?.startDatePicker.date = date
                }
            }
        }
        
        viewModel.onEndDateChanged = { [weak self] date in
            DispatchQueue.main.async {
                if let date = date {
                    self?.endDatePicker.date = date
                }
            }
        }
        
        viewModel.onIsReminderEnabledChanged = { [weak self] isEnabled in
            DispatchQueue.main.async {
                self?.reminderSwitch.isOn = isEnabled
            }
        }
    }
    
    private func loadData() {
        for button in dayButtons {
            let index = button.tag + 1
            let isSelected = viewModel.selectedDays.contains(index)
            button.backgroundColor = isSelected ? .dBlue : .lGray
            button.setTitleColor(isSelected ? .lGray : .dGray, for: .normal)
        }
        
        reminderSwitch.isOn = viewModel.isReminderEnabled
        
        if viewModel.startDate == nil {
            viewModel.startDate = viewModel.startOfDayInLocalTimeZone(for: Date())
        }
        startDatePicker.date = viewModel.startDate ?? viewModel.startOfDayInLocalTimeZone(for: Date())
        
        if let endDate = viewModel.endDate {
            endDatePicker.date = viewModel.startOfDayInLocalTimeZone(for: endDate)
        } else {
            endDatePicker.date = viewModel.startOfDayInLocalTimeZone(for: Date())
        }
        
        if let selectedPreset = viewModel.selectedPreset {
            updatePresetButtonStates(selectedButton: selectedPreset)
            
            if selectedPreset == "Свой вариант" && !viewModel.selectedDays.isEmpty {
                DispatchQueue.main.async {
                    self.dayButtonStackView.isHidden = false
                    self.dayButtonStackViewHeightConstraint.constant = 35
                    self.dayButtonStackView.alpha = 1
                    self.view.layoutIfNeeded()
                }
            }
        }
        
        viewModel.checkValidity()
    }
    
    private func updateDayButtonStates() {
        for button in dayButtons {
            let index = button.tag + 1
            if viewModel.selectedDays.contains(index) {
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
    
    // MARK: - Notification Alert
    private func showNotificationPermissionAlert() {
        let alert = UIAlertController(
            title: "Разрешение не предоставлено",
            message: "Пожалуйста, разрешите уведомления в настройках, чтобы получать напоминания о приеме лекарств",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Настройки", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showReminderActivatedAlert() {
        let alert = UIAlertController(
            title: "Напоминания включены",
            message: "Вы будете получать уведомления о приеме лекарства в установленное время",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
    }
}
