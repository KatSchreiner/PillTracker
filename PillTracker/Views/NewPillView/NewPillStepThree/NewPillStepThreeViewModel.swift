//
//  NewPillStepThreeViewModel.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 19.08.2025.
//

import UIKit

final class NewPillStepThreeViewModel {
    var model = PillStepThreeModel()
    
    var selectedPreset: String? = nil
    var selectedDays: [Int] = []
    var interval: Int?         
    var startDate: Date?
    var endDate: Date?
    var isReminderEnabled: Bool = false

    private let daysOfWeek = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]

    func calculateSelectedDaysForPreset(_ preset: String) -> [Int] {
        var selectedDays = [Int]()
        
        guard let start = startDate, let end = endDate else { return [] }
        var currentDate = start
        
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
        
        while currentDate <= end {
            let weekday = (Calendar.current.component(.weekday, from: currentDate) + 5) % 7 + 1
            selectedDays.append(weekday)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return selectedDays
    }
}
