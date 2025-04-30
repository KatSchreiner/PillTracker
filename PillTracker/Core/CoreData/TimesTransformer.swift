//
//  TimesTransformer.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 30.04.2025.
//

import Foundation

class TimesTransformer: ValueTransformer {
    
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool {
        true
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let times = value as? [(hour: String, minute: String)] else { return nil }
        return times.map { ["hour": $0.hour, "minute": $0.minute] }
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let timesArray = value as? [[String: String]] else { return nil }
        return timesArray.compactMap { dict -> (hour: String, minute: String)? in
            guard let hour = dict["hour"], let minute = dict["minute"] else { return nil }
            return (hour: hour, minute: minute)
        }
    }
}
