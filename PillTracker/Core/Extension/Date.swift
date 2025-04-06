//
//  Date.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 06.04.2025.
//

import UIKit

extension Date {
    static func datesForWeek(from date: Date) -> [Date] {
        var dates: [Date] = []
        
        let calendar = Calendar.current
        
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else {
            return dates
        }
        
        for day in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: day, to: startOfWeek) {
                dates.append(date)
            }
        }
        
        return dates
    }
}
