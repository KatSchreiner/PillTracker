//
//  StringFormatter.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 14.05.2025.
//

import Foundation

import Foundation

extension String {
    static func getUnitTitle(for dosage: Double, unit: String) -> String {
        switch unit {
        case "Капля":
            return "\(String.getPluralForm(for: dosage, singular: "Капля", plural: "Капли", pluralFew: "Капель"))"
        case "Таблетка":
            return "\(String.getPluralForm(for: dosage, singular: "Таблетка", plural: "Таблетки", pluralFew: "Таблеток"))"
        case "Капсула":
            return "\(String.getPluralForm(for: dosage, singular: "Капсула", plural: "Капсулы", pluralFew: "Капсул"))"
        case "Укол":
            return "\(String.getPluralForm(for: dosage, singular: "Укол", plural: "Укола", pluralFew: "Уколов"))"
        case "Пшик":
            return "\(String.getPluralForm(for: dosage, singular: "Пшик", plural: "Пшика", pluralFew: "Пшиков"))"
        case "Пакетик":
            return "\(String.getPluralForm(for: dosage, singular: "Пакетик", plural: "Пакетика", pluralFew: "Пакетиков"))"
        default:
            return unit
        }
    }

    private static func getPluralForm(for number: Double, singular: String, plural: String, pluralFew: String) -> String {
        
        if number.truncatingRemainder(dividingBy: 1) == 0 {
            let intNumber = Int(number)
            
            switch intNumber % 10 {
            case 1 where intNumber % 100 != 11:
                return singular
                
            case 2...4 where !(intNumber % 100 >= 12 && intNumber % 100 <= 14):
                return plural
                
            default:
                return pluralFew
            }
            
        } else {
            return pluralFew
        }
    }
}
