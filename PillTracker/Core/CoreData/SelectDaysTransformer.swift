//
//  SelectDaysTransformer.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 30.04.2025.
//

import Foundation

final class SelectedDaysTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? Set<Int> else { return nil }
        return Array(days)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let daysArray = value as? [Int] else { return nil }
        return Set(daysArray)
    }
}
