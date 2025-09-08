//
//  RepeatPreset.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 08.09.2025.
//

import Foundation

enum RepeatPreset: String, CaseIterable {
    case everyDay = "Каждый день"
    case everyOtherDay = "Через день"
    case everyTwoDays = "Через два дня"
    case custom = "Свой вариант"
    
    var interval: Int {
        switch self {
        case .everyDay: return 1
        case .everyOtherDay: return 2
        case .everyTwoDays: return 3
        case .custom: return 0
        }
    }
}
