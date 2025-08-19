//
//  MedicationNotificationManager.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 10.07.2025.
//

import UserNotifications
import UIKit

class MedicationNotificationManager {
    static let shared = MedicationNotificationManager()
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
                
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func scheduleNotification(for pill: Pill) {
        guard pill.isReminderEnabled else { return }
        cancelNotifications(for: pill.id.uuidString)
        
        let content = UNMutableNotificationContent()
        content.title = "Напоминание о приеме лекарства"
        content.body = "Примите \(pill.name)"
        content.sound = .default
        
        let center = UNUserNotificationCenter.current()
        
        for time in pill.times {
            let components = DateComponents(hour: Int(time.hour), minute: Int(time.minute))
            
            if let interval = pill.selectedInterval, interval > 0 {
                let startDate = pill.selectedStartDate
                let endDate = pill.selectedEndDate
                var currentDate = startDate
                
                while currentDate <= endDate {
                    let triggerDate = Calendar.current.date(bySettingHour: components.hour ?? 0,
                                                            minute: components.minute ?? 0,
                                                            second: 0,
                                                            of: currentDate)!
                    
                    if triggerDate >= Date() {
                        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate), repeats: false)
                        
                        let request = UNNotificationRequest(
                            identifier: "\(pill.id.uuidString)-\(triggerDate.timeIntervalSince1970)",
                            content: content,
                            trigger: trigger
                        )
                        
                        center.add(request) { error in
                            if let error = error {
                                print("Ошибка при создании уведомления: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                    currentDate = Calendar.current.date(byAdding: .day, value: interval + 1, to: currentDate)!
                }
            }
            else if !pill.selectedDays.isEmpty {
                for day in pill.selectedDays {
                    var triggerComponents = components
                    triggerComponents.weekday = day
                    
                    let trigger = UNCalendarNotificationTrigger(
                        dateMatching: triggerComponents,
                        repeats: true
                    )
                    
                    let request = UNNotificationRequest(
                        identifier: "\(pill.id.uuidString)-\(day)",
                        content: content,
                        trigger: trigger
                    )
                    
                    center.add(request) { error in
                        if let error = error {
                            print("Ошибка при создании уведомления: \(error.localizedDescription)")
                        } else {
                            print("Уведомление успешно запланировано на \(day) день недели в \(components.hour ?? 0):\(components.minute ?? 0)")
                        }
                    }
                }
            }
            else {
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: components,
                    repeats: true
                )
                
                center.add(UNNotificationRequest(
                    identifier: "\(pill.id.uuidString)-daily",
                    content: content,
                    trigger: trigger
                )) { error in
                    if let error = error {
                        print("Ошибка при создании уведомления: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func cancelNotifications(for pillId: String) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let identifiers = requests
                .filter { $0.identifier.contains(pillId) }
                .map { $0.identifier }
            
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    func checkNotificationAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
}
