//
//  PillStoreMock.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 13.03.2026.
//

import XCTest
@testable import PillTracker

final class PillStoreMock: PillStore {
    var savedPills: [Pill] = []
    var updatedPills: [Pill] = []
    var deletedPillId: [UUID] = []
    
    override func fetchPills() -> [Pill] {
        savedPills
    }
    
    override func savePill(pill: Pill) {
        savedPills.append(pill)
    }
    
    override func updatePill(_ pill: Pill) {
        updatedPills.append(pill)
    }
    
    override func deletePill(_ id: UUID) {
        deletedPillId.append(id)
        savedPills.removeAll { $0.id == id }
    }
}
