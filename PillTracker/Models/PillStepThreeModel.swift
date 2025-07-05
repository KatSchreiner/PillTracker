//
//  PillStepThreeModel.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 08.04.2025.
//

import UIKit

struct PillStepThreeModel {
    var selectedDays: [Int] = []
    var interval: Int?
    var startDate: Date?
    var endDate: Date?
    var isReminderEnabled: Bool = false
    
    func isValid() -> Bool {
        let isValid = !selectedDays.isEmpty && (startDate != nil || endDate != nil)
        return isValid
    }
}
