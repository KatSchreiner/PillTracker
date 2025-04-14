//
//  Pill.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 08.04.2025.
//

import UIKit

struct Pill {
    let id: UUID
    let icon: UIImage?
    let name: String
    let dosage: Double
    let unit: String
    let howToTake: String
    let times: [(hour: String, minute: String)]
    var selectedDays: Set<Int>
}
