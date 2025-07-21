//
//  PillsViewModel.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 20.07.2025.
//

import Foundation
import UIKit

final class PillsViewModel {
    
    // MARK: - Properties
    var selectedDate: Date = Calendar.current.startOfDay(for: Date()) {
        didSet {
            onDateUpdated?(selectedDate)
        }
    }
    
    // MARK: - Data Stores
    private let pillStore = PillStore()
    private let userStore = UserStore()
    private let takenPillsStore = TakenPillsStore()
    
    // MARK: - Data
    private var pills: [Pill] = [] {
        didSet {
            onPillsUpdated?()
        }
    }
    
    private var takenPills: [TakenPills] = [] {
        didSet {
            onTakenPillsUpdated?()
        }
    }
    
    private var userName: String? {
        didSet {
            updateUserNameLabel()
        }
    }
    
    // MARK: - Callbacks
    var onPillsUpdated: (() -> Void)?
    var onTakenPillsUpdated: (() -> Void)?
    var onUserNameUpdated: ((String) -> Void)?
    var onDateUpdated: ((Date) -> Void)?
    
    // MARK: - Public Methods
    func loadData(userName: String?) {
        self.userName = userName
        loadPills()
        loadTakenPills()
    }
    
    func loadPills() {
        pills = pillStore.fetchPills()
    }
    
    func loadTakenPills() {
        takenPills = takenPillsStore.fetchTakenPills()
    }
    
    func addOrUpdatePill(_ pill: Pill) {
        if let index = pills.firstIndex(where: { $0.id == pill.id }) {
            pills[index] = pill
            pillStore.updatePill(pill)
        } else {
            pills.append(pill)
            pillStore.savePill(pill: pill)
        }
    }
    
    func removePillTime(pillId: UUID, time: (hour: String, minute: String), date: Date, completion: @escaping (Bool) -> Void) {
        guard let index = pills.firstIndex(where: { $0.id == pillId }) else {
            completion(false)
            return
        }
        
        pills[index].times.removeAll { $0.hour == time.hour && $0.minute == time.minute }
        
        if pills[index].times.isEmpty {
            pills.remove(at: index)
            pillStore.deletePill(pillId)
        } else {
            pillStore.updatePill(pills[index])
        }
        
        takenPills.removeAll {
            $0.pillId == pillId &&
            $0.time.hour == time.hour &&
            $0.time.minute == time.minute &&
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
        
        completion(true)
    }
    
    func deletePill(_ id: UUID, completion: @escaping (Bool) -> Void) {
        pills.removeAll { $0.id == id }
        pillStore.deletePill(id)
        completion(true)
    }
    
    func togglePillTakenStatus(pill: Pill, time: (hour: String, minute: String), completion: @escaping (Bool) -> Void) {
        let isToday = Calendar.current.isDate(Date(), inSameDayAs: selectedDate)
        if !isToday {
            print("❌ Нельзя отметить лекарство, так как это не текущая дата.")
            completion(false)
            return
        }
        
        let isTaken = isPillTaken(pill: pill, time: time)
        
        if isTaken {
            takenPills.removeAll { $0.pillId == pill.id && $0.time.hour == time.hour && $0.time.minute == time.minute && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            takenPillsStore.removeTakenPill(pillId: pill.id, pill: pill, time: time, date: selectedDate)
            print("❌ Лекарство '\(pill.name)' не выпито \(formattedDateString(for: selectedDate)) в \(time.hour):\(time.minute)")
        } else {
            let newTakenPill = TakenPills(pillId: pill.id, pill: pill, time: time, date: selectedDate)
            takenPills.append(newTakenPill)
            takenPillsStore.addTakenPill(pill: pill, pillId: pill.id, time: time, date: selectedDate)
            print("✅ Лекарство '\(pill.name)' выпито \(formattedDateString(for: selectedDate)) в \(time.hour):\(time.minute)")
        }
        
        print("⚠️ Текущие отмеченные лекарства: \(takenPills.map { $0.pill.name }) на \(formattedDateString(for: selectedDate))")
        completion(true)
    }
    
    func isPillTaken(pill: Pill, time: (hour: String, minute: String)) -> Bool {
        return takenPills.contains { $0.pillId == pill.id && $0.time.hour == time.hour && $0.time.minute == time.minute && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    func handleDaySwipe(_ gesture: UISwipeGestureRecognizer, calendarView: WeeklyCalendarView, completion: @escaping (Date) -> Void) {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
        
        if gesture.direction == .left {
            if selectedDate >= weekEnd {
                calendarView.currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: calendarView.currentDate)!
            }
            selectedDate = calendar.date(byAdding: .day, value: 1, to: selectedDate)!
        } else if gesture.direction == .right {
            if selectedDate <= weekStart {
                calendarView.currentDate = calendar.date(byAdding: .weekOfYear, value: -1, to: calendarView.currentDate)!
            }
            selectedDate = calendar.date(byAdding: .day, value: -1, to: selectedDate)!
        }
        
        completion(selectedDate)
    }
    
    // MARK: - Filtering and Sorting
    func filteredPills() -> [Pill] {
        let calendar = Calendar.current
        let currentDate = Calendar.current.startOfDay(for: selectedDate)
        
        return pills.filter { pill in
            let startDate = pill.selectedStartDate
            let endDate = pill.selectedEndDate
            
            guard currentDate >= startDate && currentDate <= endDate else {
                return false
            }
            
            if let interval = pill.selectedInterval {
                let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: currentDate).day ?? 0
                if interval == 0 {
                    let weekday = (calendar.component(.weekday, from: currentDate) + 5) % 7 + 1
                    return pill.selectedDays.contains(weekday)
                } else {
                    return daysSinceStart % (interval + 1) == 0
                }
            }
            return false
        }
    }
    
    func sortedPillsWithTimes() -> [(pill: Pill, time: (hour: String, minute: String))] {
        let filtered = filteredPills()
        var pillsWithTimes: [(pill: Pill, time: (hour: String, minute: String))] = []
        
        for pill in filtered {
            for time in pill.times {
                pillsWithTimes.append((pill: pill, time: time))
            }
        }
        
        pillsWithTimes.sort { (first, second) -> Bool in
            let firstTime = "\(first.time.hour):\(first.time.minute)"
            let secondTime = "\(second.time.hour):\(second.time.minute)"
            return firstTime < secondTime
        }
        
        return pillsWithTimes
    }
    
    // MARK: - Helper Methods
    func formattedDateString(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter.string(from: date)
    }
    
    private func updateUserNameLabel() {
        let name = userName ?? "друг"
        onUserNameUpdated?("Привет, \(name)!")
    }
}
