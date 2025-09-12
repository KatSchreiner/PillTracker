//
//  NewPillStepOneViewModel.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 15.08.2025.
//

import UIKit

final class NewPillStepOneViewModel {
    
    // MARK: - Public Properties
    var pillStepOneModel = PillStepOneModel()
    
    var selectedUnit: String? {
        didSet {
            pillStepOneModel.selectedUnit = selectedUnit
            updateUnitButtonTitle?()
        }
    }
    
    var dosage: Double = 0 {
        didSet {
            updateUnitButtonTitle?()
        }
    }
    
    // MARK: - Callbacks
    var updateUnitButtonTitle: (() -> Void)?
    var updateIconButton: ((UIImage?) -> Void)?
    var onValidationChange: ((Bool) -> Void)?
    
    // MARK: - Public Methods
    func updateTitle(_ title: String?) {
        pillStepOneModel.title = title
        checkValidity()
    }
    
    func updateDosage(_ dosageText: String?) {
        if let text = dosageText, let value = Double(text) {
            dosage = value
            pillStepOneModel.dosage = value
        } else {
            dosage = 0
            pillStepOneModel.dosage = nil
        }
        checkValidity()
    }
    
    func checkValidity() {
        let isValid = pillStepOneModel.isValid()
        onValidationChange?(isValid)
    }
    
    func handleFormTypesButtonTap(presenter: UIViewController) {
        let iconSelectionView = IconSelectionViewController()
        
        iconSelectionView.selectedIcon = { [weak self] selectedIcon in
            self?.pillStepOneModel.selectedIcon = selectedIcon
            self?.updateIconButton?(selectedIcon)
            self?.checkValidity()
        }
        
        iconSelectionView.presentAsBottomSheet(on: presenter)
    }
    
    func handleUnitButtonTap(presenter: UIViewController) {
        let unitSelectionView = UnitSelectionViewController()
        
        unitSelectionView.dosage = dosage
        unitSelectionView.selectedUnit = { [weak self] selectedUnit in
            self?.selectedUnit = selectedUnit
            self?.pillStepOneModel.selectedUnit = selectedUnit
            self?.updateUnitButtonTitle?()
            self?.checkValidity()
        }
        
        unitSelectionView.presentAsBottomSheet(on: presenter)
    }
    
    func shouldChangeCharactersInDosageField(_ string: String, currentText: String, range: NSRange) -> Bool {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.")
        let characterSet = CharacterSet(charactersIn: string)
        guard allowedCharacters.isSuperset(of: characterSet) else { return false }
        
        if string == "." {
            return !currentText.contains(".")
        }
        
        return true
    }
    
    func formattedDosageText() -> String? {
        guard let dosage = pillStepOneModel.dosage else { return nil }
        return String(format: "%.1f", dosage)
    }
    
    func keyboardWillShowTransform(keyboardHeight: CGFloat) -> CGAffineTransform {
        return CGAffineTransform(translationX: 0, y: -keyboardHeight / 2)
    }
    
    func keyboardWillHideTransform() -> CGAffineTransform {
        return .identity
    }
}

extension NewPillStepOneViewModel {
    func configure(with model: PillStepOneModel) {
        self.pillStepOneModel = model
        self.selectedUnit = model.selectedUnit
        self.dosage = model.dosage ?? 0
        updateUnitButtonTitle?()
        updateIconButton?(model.selectedIcon)
        checkValidity()
    }
}
