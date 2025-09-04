//
//  NewPillStepThreeViewModel.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 19.08.2025.
//

import UIKit

final class NewPillStepThreeViewModel {
    var model = PillStepThreeModel()
    
    var selectedPreset: String? = nil {
        didSet { onSelectedPresetChanged?(selectedPreset) }
    }
    var selectedDays: [Int] = [] {
        didSet { onSelectedDaysChanged?(selectedDays) }
    }
    var interval: Int? {
        didSet { onIntervalChanged?(interval) }
    }
    var startDate: Date? {
        didSet { onStartDateChanged?(startDate) }
    }
    var endDate: Date? {
        didSet { onEndDateChanged?(endDate) }
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
    
    let daysOfWeek = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]

    init() {
        startDate = startOfDayInLocalTimeZone(for: Date())
    }
    
    func calculateSelectedDaysForPreset(_ preset: String) -> [Int] {
        guard let start = startDate, let end = endDate else { return [] }
        var selectedDays = [Int]()
        var intervalDays: Int = 1
        
        switch preset {
        case "Каждый день":
            intervalDays = 1
        case "Через день":
            intervalDays = 2
        case "Через 2 дня":
            intervalDays = 3
        default:
            return []
        }
        
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
    
    func startOfDayInLocalTimeZone(for date: Date) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return calendar.startOfDay(for: date)
    }
    
    func weekdayNumber(from date: Date) -> Int {
        let calendar = Calendar.current
        return (calendar.component(.weekday, from: date) + 5) % 7 + 1
    }
    
    func isValid() -> Bool {
        guard startDate != nil && endDate != nil else { return false }
        
        if let end = endDate, let start = startDate, end < start {
            return false
        }
        
        if selectedPreset != "Свой вариант" {
            return true
        }
        
        return !selectedDays.isEmpty
    }
}

extension NewPillStepThreeViewModel {
    func configure(with model: PillStepThreeModel) {
        self.model = model
        self.selectedPreset = model.selectedPreset
        self.selectedDays = model.selectedDays
        self.interval = model.interval
        self.startDate = model.startDate
        self.endDate = model.endDate
        self.isReminderEnabled = model.isReminderEnabled
    }
}
