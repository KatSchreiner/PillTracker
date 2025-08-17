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
            DispatchQueue.main.async { [weak self] in
                self?.onTimesUpdated?()
            }
            
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
    
    func sortTimes() {
        guard !selectedTimes.isEmpty else { return }
        
        selectedTimes = selectedTimes.sorted { (time1, time2) -> Bool in
            if let hour1 = Int(time1.hour), let hour2 = Int(time2.hour) {
                if hour1 != hour2 {
                    return hour1 < hour2
                }
                if let minute1 = Int(time1.minute), let minute2 = Int(time2.minute) {
                    return minute1 < minute2
                }
            }
            return false
        }
    }
}
