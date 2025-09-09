//
//  NewPillStepThreeViewModel.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 19.08.2025.
//

import UIKit

final class NewPillStepThreeViewModel {
    var pillStepThreeModel = PillStepThreeModel()
    
    var selectedPreset: String? = nil {
        didSet {
            onSelectedPresetChanged?(selectedPreset)
            checkValidity()
        }
    }
    
    var selectedDays: [Int] = [] {
        didSet {
            DispatchQueue.main.async {
                self.onSelectedDaysChanged?(self.selectedDays)
            }
            checkValidity()
        }
    }
    
    var interval: Int? {
        didSet { onIntervalChanged?(interval) }
    }
    
    var startDate: Date? {
        didSet {
            onStartDateChanged?(startDate)
            checkValidity()
        }
    }
    var endDate: Date? {
        didSet {
            onEndDateChanged?(endDate)
            recalculateSelectedDaysIfNeeded()
            checkValidity()
        }
    }
    var isReminderEnabled: Bool = false {
        didSet { onIsReminderEnabledChanged?(isReminderEnabled) }
    }

    var onSelectedPresetChanged: ((String?) -> Void)?
    var onSelectedDaysChanged: (([Int]) -> Void)?
    var onIntervalChanged: ((Int?) -> Void)?
    var onStartDateChanged: ((Date?) -> Void)?
    var onEndDateChanged: ((Date?) -> Void)?
    var onIsReminderEnabledChanged: ((Bool) -> Void)?
    var onValidationChange: ((Bool) -> Void)?
    
    let daysOfWeek = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]

    init() {
        startDate = startOfDayInLocalTimeZone(for: Date())
    }
    
    func calculateSelectedDaysForPreset(_ preset: String) -> [Int] {
        guard let repeatPreset = RepeatPreset(rawValue: preset),
              repeatPreset != .custom else { return [] }
        
        guard let start = startDate, let end = endDate, start <= end else { return [] }

        let intervalDays = repeatPreset.interval
        
        var selectedDays = [Int]()
        var currentDate = start
        
        while currentDate <= end {
            let weekday = weekdayNumber(from: currentDate)
            if !selectedDays.contains(weekday) {
                selectedDays.append(weekday)
            }
            guard let nextDate = Calendar.current.date(byAdding: .day, value: intervalDays, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return selectedDays
    }
    
    private func recalculateSelectedDaysIfNeeded() {
        guard let preset = selectedPreset,
              preset != RepeatPreset.custom.rawValue else { return }
        
        selectedDays = calculateSelectedDaysForPreset(preset)
    }
    
    func startOfDayInLocalTimeZone(for date: Date) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar.startOfDay(for: date)
    }
    
    func weekdayNumber(from date: Date) -> Int {
        let calendar = Calendar.current
        return (calendar.component(.weekday, from: date) + 5) % 7 + 1
    }
    
    func checkValidity() {
        pillStepThreeModel.selectedDays = selectedDays
        pillStepThreeModel.selectedPreset = selectedPreset
        pillStepThreeModel.startDate = startDate
        pillStepThreeModel.endDate = endDate
        pillStepThreeModel.interval = interval
        pillStepThreeModel.isReminderEnabled = isReminderEnabled
        
        let isValid = pillStepThreeModel.isValid()
        onValidationChange?(isValid)
    }
}

extension NewPillStepThreeViewModel {
    func configure(with model: PillStepThreeModel) {
        self.pillStepThreeModel = model
        self.selectedPreset = model.selectedPreset
        self.selectedDays = model.selectedDays
        self.interval = model.interval
        self.startDate = model.startDate
        self.endDate = model.endDate
        self.isReminderEnabled = model.isReminderEnabled
    }
}
