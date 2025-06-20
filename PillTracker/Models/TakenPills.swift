//
//  TakenPills.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 10.05.2025.
//

import Foundation

struct TakenPills {
    let pillId: UUID
    let pill: Pill
    let time: (hour: String, minute: String)
    let date: Date
}
