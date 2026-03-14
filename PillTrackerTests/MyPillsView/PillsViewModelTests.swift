//
//  PillsViewModelTests.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 10.03.2026.
//

import XCTest
@testable import PillTracker

final class PillsViewModelTests: XCTestCase {
    var viewModel: PillsViewModel?
    var pillStoreMock: PillStoreMock?
    
    override func setUp() {
        super.setUp()
        pillStoreMock = PillStoreMock()
        if let mock = pillStoreMock {
            viewModel = PillsViewModel(pillStore: mock)
        }
    }
    
    override func tearDown() {
        viewModel = nil
        pillStoreMock = nil
        super.tearDown()
    }
    
    func testAddOrUpdatePill_addsNewPill() throws {
        let viewModel = try XCTUnwrap(self.viewModel)
        let pillStoreMock = try XCTUnwrap(self.pillStoreMock)
        
        pillStoreMock.savedPills.removeAll()
        pillStoreMock.updatedPills.removeAll()
        pillStoreMock.deletedPillId.removeAll()
        
        let pill = try makeTestPill()
        pillStoreMock.savedPills = []
        
        viewModel.addOrUpdatePill(pill)
        
        XCTAssertEqual(pillStoreMock.savedPills.count, 1)
        XCTAssertEqual(viewModel.sortedPillsWithTimes().count, pill.times.count)
    }
    
    func testDeletePill_removesPill() throws {
        let viewModel = try XCTUnwrap(self.viewModel)
        let pillStoreMock = try XCTUnwrap(self.pillStoreMock)
        
        pillStoreMock.savedPills = []
        pillStoreMock.deletedPillId = []
        
        let pill = try makeTestPill()
        viewModel.addOrUpdatePill(pill)
        
        XCTAssertEqual(pillStoreMock.savedPills.count, 1)
        
        let expectation = expectation(description: "Лекарство удалено")
        
        viewModel.deletePill(pill.id) { succes in
          XCTAssert(succes)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(pillStoreMock.deletedPillId.count, 1)
        XCTAssertEqual(pillStoreMock.deletedPillId.first, pill.id)
        XCTAssertFalse(viewModel.sortedPillsWithTimes().contains { $0.pill.id == pill.id })
    }
        
    private func makeTestPill() throws -> Pill {
        let calendar = Calendar.current
            let todayStart = calendar.startOfDay(for: Date())
            let weekday = (calendar.component(.weekday, from: todayStart) + 5) % 7 + 1
        
        guard let endDate = calendar.date(byAdding: .day, value: 7, to: todayStart) else {
            struct DateError: Error {}
            throw DateError()
        }

            return Pill(
                id: UUID(),
                icon: nil,
                name: "Тестовое лекарство",
                dosage: 1.0,
                unit: "таб",
                howToTake: "Не важно",
                times: [("08", "00")],
                selectedDays: [weekday],
                selectedInterval: 0,
                selectedStartDate: todayStart,
                selectedEndDate: endDate,
                isReminderEnabled: true
            )
    }
}
