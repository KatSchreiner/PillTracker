//
//  NewPillStepTwoViewModel.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 17.08.2025.
//

import UIKit

final class NewPillStepTwoViewModel {
    
    // MARK: - Public Properties
    var pillStepTwoModel = PillStepTwoModel()
    
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
    
    // MARK: - Callbacks
    var onTimesUpdated: (() -> Void)?
    var onValidationChange: ((Bool) -> Void)?
    
    // MARK: - Public Methods
    func setSelectedOption(_ option: String?) {
        selectedOption = option
        pillStepTwoModel.selectedOption = option
        checkValidity()
    }
    
    func addTime(hour: String, minute: String) {
        selectedTimes.append((hour: hour, minute: minute))
        pillStepTwoModel.selectedTimes = selectedTimes
        checkValidity()
    }
    
    func removeTime(at index: Int) {
        guard index < selectedTimes.count else { return }
        selectedTimes.remove(at: index)
        pillStepTwoModel.selectedTimes = selectedTimes
        checkValidity()
    }
    
    func checkValidity() {
        pillStepTwoModel.selectedOption = selectedOption
        pillStepTwoModel.selectedTimes = selectedTimes
        
        let isValid = pillStepTwoModel.isValid()
        onValidationChange?(isValid)
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

extension NewPillStepTwoViewModel {
    func configure(with model: PillStepTwoModel) {
        self.selectedOption = model.selectedOption
        self.selectedTimes = model.selectedTimes
        onTimesUpdated?()
        checkValidity()
    }
}
