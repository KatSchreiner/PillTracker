//
//  NewPillStepTwoViewModel.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 17.08.2025.
//

import UIKit

final class NewPillStepTwoViewModel {

    var selectedTimes: [(hour: String, minute: String)] = [] {
        didSet {
            onTimesUpdated?()
        }
    }
    
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
    
    var isNextButtonEnabled: Bool {
        return isValid()
    }
    
    var onTimesUpdated: (() -> Void)?
    var onNextButtonStateChanged: ((Bool) -> Void)?
    var onLoadData: (() -> Void)?

    func setSelectedOption(_ option: String?) {
        selectedOption = option
        updateNextButtonState()
    }
    
    func addTime(hour: String, minute: String) {
        selectedTimes.append((hour: hour, minute: minute))
        updateNextButtonState()
    }
    
    func removeTime(at index: Int) {
        guard index < selectedTimes.count else { return }
        selectedTimes.remove(at: index)
        updateNextButtonState()
    }
    
    func isValid() -> Bool {
        return selectedTimes.count > 0 && selectedOption != nil
    }
    
    func updateNextButtonState() {
        onNextButtonStateChanged?(isNextButtonEnabled)
    }
    
    func loadData(from model: PillStepTwoModel) {
        selectedOption = model.selectedOption
        selectedTimes = model.selectedTimes
        
        updateNextButtonState()
        
        onTimesUpdated?()
    }
}
