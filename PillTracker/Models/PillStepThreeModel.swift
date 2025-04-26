//
//  PillStepThreeModel.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 08.04.2025.
//

import UIKit

struct PillStepThreeModel {
    var selectedDays: Set<Int> = []
    var isReminderEnabled: Bool = false
    
    func isValid() -> Bool {
        let isValid = !selectedDays.isEmpty
        print("isValid: \(isValid), selectedDays: \(selectedDays)") 
        return isValid
    }
}
