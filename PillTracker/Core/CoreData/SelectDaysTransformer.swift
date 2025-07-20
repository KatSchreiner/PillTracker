//
//  SelectDaysTransformer.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 30.04.2025.
//

import Foundation

final class SelectedDaysTransformer: ValueTransformer {

    override class func transformedValueClass() -> AnyClass { return NSData.self }

    override class func allowsReverseTransformation() -> Bool { return true }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [Int] else { return nil }
        do {
            let data = try JSONEncoder().encode(days)
            return data as NSData
        } catch {
            print("Ошибка при кодировании selectedDays: \(error)")
            return nil
        }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        do {
            let days = try JSONDecoder().decode([Int].self, from: data)
            return days
        } catch {
            print("Ошибка при декодировании selectedDays: \(error)")
            return nil
        }
    }
}
