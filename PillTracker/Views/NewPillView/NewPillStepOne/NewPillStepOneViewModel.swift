//
//  NewPillStepOneViewModel.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 15.08.2025.
//

import UIKit

class NewPillStepOneViewModel {
    static let stepOne = "NewPillStepOneCell"
    var pillStepOneModel: PillStepOneModel?
    
    var selectedUnit: String?
    var dosage: Double = 0 {
        didSet {
            updateUnitButtonTitle?()
        }
    }
    var titleText: String? {
        didSet {
            pillStepOneModel?.title = titleText
        }
    }
    var dosageText: String? {
        didSet {
            if let dosageText = dosageText, let dosageValue = Double(dosageText) {
                pillStepOneModel?.dosage = dosageValue
                dosage = dosageValue
            } else {
                pillStepOneModel?.dosage = nil
                dosage = 0
            }
        }
    }
    
    var updateUnitButtonTitle: (() -> Void)?
    var updateNextButtonState: (() -> Void)?
    var updateIconButton: ((UIImage?) -> Void)?
    var updateKeyboardPosition: ((CGFloat, Bool) -> Void)?
        
    // MARK: - Initialization
    
    // MARK: - Button Actions
    func handleFormTypesButtonTap(presenter: UIViewController) {
        let iconSelectionView = IconSelectionViewController()
        
        iconSelectionView.selectedIcon = { [weak self] selectedIcon in
            self?.pillStepOneModel?.selectedIcon = selectedIcon
            self?.updateIconButton?(selectedIcon)
            self?.updateNextButtonState?()
        }
        
        iconSelectionView.presentAsBottomSheet(on: presenter)
    }
    
    func handleUnitButtonTap(presenter: UIViewController) {
        let unitSelectionView = UnitSelectionViewController()
        
        unitSelectionView.dosage = dosage
        unitSelectionView.selectedUnit = { [weak self] selectedUnit in
            self?.selectedUnit = selectedUnit
            self?.pillStepOneModel?.selectedUnit = selectedUnit
            self?.updateUnitButtonTitle?()
            self?.updateNextButtonState?()
        }
        
        unitSelectionView.presentAsBottomSheet(on: presenter)
    }
    
    func loadData(titleTextField: UITextField? = nil,
                     dosageTextField: UITextField? = nil,
                     unitButton: UIButton? = nil,
                     formTypesButton: UIButton? = nil) {
            titleTextField?.text = pillStepOneModel?.title
            titleText = pillStepOneModel?.title
            
            if let dosage = pillStepOneModel?.dosage {
                dosageTextField?.text = String(format: "%.1f", dosage)
                dosageText = String(format: "%.1f", dosage)
            } else {
                dosageTextField?.text = nil
                dosageText = nil
            }
            
            if let selectedIcon = pillStepOneModel?.selectedIcon {
                formTypesButton?.setImage(selectedIcon, for: .normal)
                updateIconButton?(selectedIcon)
            }
            
            if let selectedUnit = pillStepOneModel?.selectedUnit {
                self.selectedUnit = selectedUnit
                let unitTitle = String.getUnitTitle(for: dosage, unit: selectedUnit)
                unitButton?.setTitle(unitTitle, for: .normal)
            }
        }

    // MARK: - TextField Validation
    func shouldChangeCharactersInDosageField(_ string: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
