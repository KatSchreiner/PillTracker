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
        stackView.spacing = Constants.smallPadding
        
        RepeatPreset.allCases.forEach { preset in
            let button = createPresetButton(
                title: preset.rawValue,
                action: #selector(presetButtonTapped(_:))
            )
            button.tag = preset.hashValue
            stackView.addArrangedSubview(button)
            
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        }
        
        return stackView
    }()
    
    private func createPresetButton(title: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.dGray, for: .normal)
        button.backgroundColor = .lGray
        button.layer.cornerRadius = Constants.defaultRadius
        button.isEnabled = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private lazy var dayButtons: [UIButton] = []
    
    private lazy var dayButtonStackView: UIStackView = {
        let dayButtonStackView = UIStackView()
        dayButtonStackView.axis = .horizontal
        dayButtonStackView.distribution = .fillEqually
        dayButtonStackView.spacing = Constants.smallPadding
        
        for (index, day) in viewModel.daysOfWeek.enumerated() {
            let button = UIButton()
            button.layer.cornerRadius = Constants.defaultRadius
            button.backgroundColor = .lGray
            button.setTitle(day, for: .normal)
            button.setTitleColor(.gray, for: .normal)
            button.titleLabel?.font = Constants.defaultFontSize
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
        startDateStackView.spacing = Constants.smallPadding
        return startDateStackView
    }()
    
    private lazy var endDateStackView: UIStackView = {
        let endDateStackView = UIStackView(arrangedSubviews: [endDateLabel, endDatePicker])
        endDateStackView.axis = .horizontal
        endDateStackView.spacing = Constants.smallPadding
        return endDateStackView
    }()
    
    private lazy var customDateRangeStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [startDateStackView, endDateStackView])
        stackView.axis = .vertical
        stackView.spacing = Constants.smallPadding
        return stackView
    }()
    
    private lazy var reminderLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.defaultFontSize
        label.textColor = .dGray
        label.text = "Напомнить?"
        label.textAlignment = .left
        return label
    }()
    
    private lazy var reminderSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = false
        switchControl.addTarget(self, action: #selector(didToggleReminderSwitch), for: .valueChanged)
        switchControl.onTintColor = .dBlue
        switchControl.tintColor = .lGray
        return switchControl
    }()
    
    private lazy var reminderStackView: UIStackView = {
        let reminderStackView = UIStackView(arrangedSubviews: [reminderLabel, reminderSwitch])
        reminderStackView.axis = .horizontal
        reminderStackView.spacing = Constants.defaultPadding
        return reminderStackView
    }()
    
    private var dayButtonStackViewHeightConstraint: NSLayoutConstraint?
    private var isDurationSet: Bool = false
    private var currentAlertController: UIAlertController?
    
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        loadData()
    }
    
    // MARK: - IB Actions
    @objc private func presetButtonTapped(_ sender: UIButton) {
        sender.animatePress()
        
        guard let buttonTitle = sender.title(for: .normal),
              let preset = RepeatPreset(rawValue: buttonTitle) else {
            return
        }
        handlePresetSelection(preset)
    }
    
    @objc
    private func didTapDayButton(sender: UIButton) {
        sender.isSelected.toggle()
        
        let index = sender.tag + 1
        
        if let itemIndex = viewModel.selectedDays.firstIndex(of: index) {
            viewModel.selectedDays.remove(at: itemIndex)
        } else {
            viewModel.selectedDays.append(index)
        }
        
        updateDayButtonStates()
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
                    if !granted {
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
        dayButtonStackViewHeightConstraint?.isActive = true
        
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
            
            reminderStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
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
                if preset == RepeatPreset.custom.rawValue {
                    self?.showDayButtonStackView()
                } else {
                    self?.hideDayButtonStackView()
                    self?.resetDayButtons()
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
        if viewModel.selectedPreset == RepeatPreset.custom.rawValue {
            showDayButtonStackView()
        } else {
            hideDayButtonStackView()
            resetDayButtons()
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
            
            if selectedPreset == RepeatPreset.custom.rawValue {
                showDayButtonStackView()
            } else {
                hideDayButtonStackView()
            }
        }
        
        viewModel.checkValidity()
    }
    
    private func handlePresetSelection(_ preset: RepeatPreset) {
        viewModel.selectedDays = []
        resetDayButtons()
        
        if preset != .custom {
            hideDayButtonStackView()
            viewModel.selectedDays = viewModel.calculateSelectedDaysForPreset(preset.rawValue)
            viewModel.interval = preset.interval - 1
        } else {
            showDayButtonStackView()
            viewModel.interval = nil
        }
        
        viewModel.selectedPreset = preset.rawValue
        updatePresetButtonStates(selectedButton: preset.rawValue)
        updateDayButtonStates()
        viewModel.checkValidity()
    }
    
    private func updateDayButtonStates() {
        for button in dayButtons {
            let index = button.tag + 1
            let isSelected = viewModel.selectedDays.contains(index)
            
            UIView.performWithoutAnimation {
                button.isSelected = isSelected
                button.backgroundColor = isSelected ? .dBlue : .lGray
                button.setTitleColor(isSelected ? .lGray : .dGray, for: .normal)
                button.layoutIfNeeded()
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
    
    private func resetDayButtons() {
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                for button in self.dayButtons {
                    button.isSelected = false
                    button.isHighlighted = false
                    button.backgroundColor = .lGray
                    button.setTitleColor(.dGray, for: .normal)
                    button.layoutIfNeeded()
                }
            }
        }
    }
    
    private func showDayButtonStackView() {
        guard dayButtonStackView.alpha == 0 else { return }
        
        dayButtonStackView.isHidden = false
        dayButtonStackViewHeightConstraint?.constant = 35
        
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3) {
            self.dayButtonStackView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideDayButtonStackView() {
        guard dayButtonStackView.alpha == 1 else { return }
        resetDayButtons()
        
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.dayButtonStackView.alpha = 0
            },
            completion: { _ in
                self.dayButtonStackView.isHidden = true
                self.dayButtonStackViewHeightConstraint?.constant = 0
            }
        )
    }
}
