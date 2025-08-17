//
//  NewPillStepTwoViewModel.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 17.08.2025.
//

import UIKit

final class NewPillStepTwoViewModel {
    var model: PillStepTwoModel?
    
    var selectedTimes: [(hour: String, minute: String)] = []
    
    var selectedOption: String?
    let optionData = ["До еды", "Во время еды", "После еды", "Не важно"]
    let optionImages = [
        UIImage(named: "beforeEat")?.withRenderingMode(.alwaysOriginal),
        UIImage(named: "duringEat")?.withRenderingMode(.alwaysOriginal),
        UIImage(named: "afterEat")?.withRenderingMode(.alwaysOriginal),
        UIImage(named: "beforeEat")?.withRenderingMode(.alwaysOriginal)
    ]
    let optionImagesColor = [
        UIImage(named: "beforeEatColor")?.withRenderingMode(.alwaysOriginal),
        UIImage(named: "duringEatColor")?.withRenderingMode(.alwaysOriginal),
        UIImage(named: "afterEatColor")?.withRenderingMode(.alwaysOriginal),
        UIImage(named: "beforeEatColor")?.withRenderingMode(.alwaysOriginal)
    ]
    
    func removeTime(at index: Int) {
        guard index < selectedTimes.count else { return }
        selectedTimes.remove(at: index)
    }
}
