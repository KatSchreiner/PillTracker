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
    
    var updateUnitButtonTitle: (() -> Void)?
    var updateNextButtonState: (() -> Void)?
    var updateIconButton: ((UIImage?) -> Void)?
    
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
 
    // MARK: - TextField Validation
    func shouldChangeCharactersInDosageField(_ string: String) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
