//
//  AddNewPillViewModel.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 14.08.2025.
//

import UIKit

class AddNewPillViewModel {
    
    // MARK: - Public Properties
    var pillStepOneModel = PillStepOneModel()
    var pillStepTwoModel = PillStepTwoModel()
    var pillStepThreeModel = PillStepThreeModel()
    
    var isEditingPill: Bool
    var editedPillId: UUID?
    var currentStep: AddPillStep = .stepOne
    var doneButtonTitle: String = "Готово"
    
    weak var currentChildVC: UIViewController?
    
    var onUpdateControls: ((AddPillStep) -> Void)?
    var onProgressUpdate: ((Float) -> Void)?
    var onPillCreated: ((Pill) -> Void)?
    var onNavigationPop: (() -> Void)?
    var onPrintDetails: ((Pill) -> Void)?
    
    // MARK: - Initialization
    init(isEditingPill: Bool = false, editedPillId: UUID? = nil) {
        self.isEditingPill = isEditingPill
        self.editedPillId = editedPillId
        self.doneButtonTitle = isEditingPill ? "Обновить" : "Готово"
    }
    
    func didTapDoneButton() {
        moveToStepThree()
        let pill = createPill()
        
        MedicationNotificationManager.shared.requestAuthorization { [weak self] granted in
            DispatchQueue.main.async {
                if granted && pill.isReminderEnabled {
                    MedicationNotificationManager.shared.scheduleNotification(for: pill)
                }
                
                self?.onPillCreated?(pill)
                self?.printPillDetails(pill)
                self?.onNavigationPop?()
            }
        }
    }
    
    func didTapCancelButton() {
        onNavigationPop?()
    }
    
    func goToNextStep() {
        guard let currentIndex = AddPillStep.allCases.firstIndex(of: currentStep),
              currentIndex < AddPillStep.allCases.count - 1 else { return }
        
        updateCurrentStep(to: currentIndex + 1)
    }
    
    func goToPreviousStep() {
        guard let currentIndex = AddPillStep.allCases.firstIndex(of: currentStep),
              currentIndex > 0 else { return }
        
        updateCurrentStep(to: currentIndex - 1)
    }
    
    // MARK: - Step Management
    private func updateCurrentStep(to newIndex: Int) {
        let isMovingForward = newIndex > AddPillStep.allCases.firstIndex(of: currentStep)!
        
        switch currentStep {
        case .stepOne:
            moveToStepOne()
        case .stepTwo:
            moveToStepTwo()
        case .stepThree:
            moveToStepThree()
        }
        
        currentStep = AddPillStep.allCases[newIndex]
        onUpdateControls?(currentStep)
        updateProgress()
    }
    
    private func moveToStepOne() {
        guard let stepOneVC = currentChildVC as? NewPillStepOneViewController else { return }
        
        // Обновляем модель первого шага данными из view controller'а
        pillStepOneModel.title = stepOneVC.titleTextField.text
        
        if let dosageText = stepOneVC.dosageTextField.text,
           let dosageValue = Double(dosageText) {
            pillStepOneModel.dosage = dosageValue
        } else {
            pillStepOneModel.dosage = nil
        }
        
        pillStepOneModel.selectedIcon = stepOneVC.formTypesButton.image(for: .normal)
        pillStepOneModel.selectedUnit = stepOneVC.viewModel.selectedUnit
    }

    private func moveToStepTwo() {
        guard let stepTwoVC = currentChildVC as? NewPillStepTwoViewController else { return }
        
        stepTwoVC.updateSelectedTimes()
        pillStepTwoModel.selectedTimes = stepTwoVC.viewModel.selectedTimes
        pillStepTwoModel.selectedIcon = pillStepOneModel.selectedIcon
        pillStepTwoModel.selectedOption = stepTwoVC.model.selectedOption
        
        stepTwoVC.viewModel.selectedTimes = pillStepTwoModel.selectedTimes
        stepTwoVC.viewModel.selectedOption = pillStepTwoModel.selectedOption
    }

    private func moveToStepThree() {
        guard let stepThreeVC = currentChildVC as? NewPillStepThreeViewController else { return }
        
        pillStepThreeModel.selectedDays = stepThreeVC.model.selectedDays
        pillStepThreeModel.selectedPreset = stepThreeVC.model.selectedPreset
        pillStepThreeModel.interval = stepThreeVC.model.interval
        pillStepThreeModel.startDate = stepThreeVC.model.startDate
        pillStepThreeModel.endDate = stepThreeVC.model.endDate
        pillStepThreeModel.isReminderEnabled = stepThreeVC.model.isReminderEnabled
    }
    
    func updateProgress() {
        let progress = Float(currentStep.rawValue + 1) / Float(AddPillStep.allCases.count)
        onProgressUpdate?(progress)
    }
    
    // MARK: - Pill Creation
    private func createPill() -> Pill {
        let formattedUnitTitle = String.getUnitTitle(
            for: pillStepOneModel.dosage ?? 0.0,
            unit: pillStepOneModel.selectedUnit ?? ""
        )
        
        let pillId = isEditingPill ? editedPillId ?? UUID() : UUID()
        
        return Pill(
            id: pillId,
            icon: pillStepOneModel.selectedIcon,
            name: pillStepOneModel.title ?? "",
            dosage: pillStepOneModel.dosage ?? 0.0,
            unit: formattedUnitTitle,
            howToTake: pillStepTwoModel.selectedOption ?? "",
            times: pillStepTwoModel.selectedTimes,
            selectedDays: pillStepThreeModel.selectedDays,
            selectedInterval: pillStepThreeModel.interval ?? 0,
            selectedStartDate: pillStepThreeModel.startDate ?? Date(),
            selectedEndDate: pillStepThreeModel.endDate ?? Date(),
            isReminderEnabled: pillStepThreeModel.isReminderEnabled
        )
    }
    
    private func printPillDetails(_ pill: Pill) {
        print("Данные переданы:")
        print("ID лекарства: \(pill.id)")
        print("Иконка: \(pillStepOneModel.selectedIcon?.description ?? "nil")")
        print("Название лекарства: \(pillStepOneModel.title ?? "nil")")
        print("Дозировка: \(pillStepOneModel.dosage ?? 0.0)")
        print("Единица измерения: \(pillStepOneModel.selectedUnit ?? "nil")")
        print("Время приема: \(String(describing: pillStepTwoModel.selectedTimes))")
        print("Как принимать: \(pillStepTwoModel.selectedOption ?? "nil")")
        print("Выбранные дни: \(pillStepThreeModel.selectedDays)")
        print("Интервал: через \(String(describing: pillStepThreeModel.interval))")
        print("Напомнить: \(pillStepThreeModel.isReminderEnabled)")
        print("Начало лечения: \(String(describing: pillStepThreeModel.startDate))")
        print("Окончание лечения: \(String(describing: pillStepThreeModel.endDate))")
        
        onPrintDetails?(pill)
    }
}
