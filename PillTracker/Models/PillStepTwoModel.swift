//
//  PillStepTwoModel.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 08.04.2025.
//

import UIKit

struct PillStepTwoModel {
    var selectedTimes: [(hour: String, minute: String)] = []
    var selectedOption: String?
    var selectedIcon: UIImage?
    
    func isValid() -> Bool {
        return !selectedTimes.isEmpty && selectedOption != nil
    }
}
