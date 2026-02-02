//
//  NewPillStepTwoViewModel.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 17.08.2025.
//

import UIKit

final class NewPillStepTwoViewModel {
    
    // MARK: - Public Properties
    var selectedIndex: Int? {
        didSet {
            onOptionSelected?(selectedIndex)
        }
    }
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
    let optionImagesDefault = [
        UIImage(named: "beforeEat")?.withRenderingMode(.alwaysOriginal),
        UIImage(named: "duringEat")?.withRenderingMode(.alwaysOriginal),
        UIImage(named: "afterEat")?.withRenderingMode(.alwaysOriginal),
        UIImage(named: "beforeEat")?.withRenderingMode(.alwaysOriginal)
    ]
    let optionImagesSelected = [
        UIImage(named: "beforeEatColor")?.withRenderingMode(.alwaysOriginal),
        UIImage(named: "duringEatColor")?.withRenderingMode(.alwaysOriginal),
        UIImage(named: "afterEatColor")?.withRenderingMode(.alwaysOriginal),
        UIImage(named: "beforeEatColor")?.withRenderingMode(.alwaysOriginal)
    ]
    
    // MARK: - Callbacks
    var onTimesUpdated: (() -> Void)?
    var onValidationChange: ((Bool) -> Void)?
    var onOptionSelected: ((Int?) -> Void)?
    
    // MARK: - Public Methods
    func setSelectedOption(_ option: String?) {
        selectedOption = option
        selectedIndex = optionData.firstIndex(of: option ?? "")
        pillStepTwoModel.selectedOption = option
        pillStepTwoModel.selectedIcon = selectedIndex != nil ? optionImagesSelected[selectedIndex!] : nil
        checkValidity()
    }
    
    func getSelectedIndex() -> Int? {
        return selectedIndex ?? optionData.firstIndex(of: selectedOption ?? "")
    }
    
    func addTime(hour: String, minute: String) {
        selectedTimes.append((hour: hour, minute: minute))
        sortTimes()
        pillStepTwoModel.selectedTimes = selectedTimes
        checkValidity()
    }
    
    func removeTime(at index: Int) {
        print("Removing time at index \(index), current count: \(selectedTimes.count)")

        guard index < selectedTimes.count else {
            print("Index out of bounds")
            return
        }
        selectedTimes.remove(at: index)
        print("New count: \(selectedTimes.count)")

        pillStepTwoModel.selectedTimes = selectedTimes
        checkValidity()
    }
    
    func updateTime(at index: Int, hour: String, minute: String) {
        guard index >= 0 && index < selectedTimes.count else { return }
        
        selectedTimes[index] = (hour: hour, minute: minute)
        sortTimes()
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
        let sorted = selectedTimes.sorted { time1, time2 in
            var components1: DateComponents = DateComponents()
            components1.hour = Int(time1.hour)
            components1.minute = Int(time1.minute)
            
            var components2: DateComponents = DateComponents()
            components2.hour = Int(time2.hour)
            components2.minute = Int(time2.minute)
            
            let date1 = Calendar.current.date(from: components1) ?? Date.distantPast
            let date2 = Calendar.current.date(from: components2) ?? Date.distantPast
            
            return date1 < date2
        }
        
        selectedTimes = sorted
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
