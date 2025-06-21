//
//  EditMyPillViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 02.05.2025.
//

import UIKit

final class EditMyPillViewController: UIViewController {
    let userStore = UserStore()
    
    var pill: Pill?
    weak var delegate: AddNewPillDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        view.backgroundColor = .systemBackground
        
        let addNewPillVC = AddNewPillViewController()
        addNewPillVC.delegate = self
        
        if let pill = pill {
            addNewPillVC.isEditingPill = true
            addNewPillVC.editedPillId = pill.id
            
            addNewPillVC.pillStepOneModel.title = pill.name
            addNewPillVC.pillStepOneModel.dosage = pill.dosage
            addNewPillVC.pillStepOneModel.selectedIcon = pill.icon
            addNewPillVC.pillStepOneModel.selectedUnit = pill.unit
            
            addNewPillVC.pillStepTwoModel.selectedTimes = pill.times
            addNewPillVC.pillStepTwoModel.selectedOption = pill.howToTake
            
            addNewPillVC.pillStepThreeModel.selectedDays = pill.selectedDays
            addNewPillVC.pillStepThreeModel.startDate = pill.selectedStartDate
            addNewPillVC.pillStepThreeModel.endDate = pill.selectedEndDate
        }
        
        addChild(addNewPillVC)
        view.addSubview(addNewPillVC.view)
        addNewPillVC.view.frame = view.bounds
        addNewPillVC.didMove(toParent: self)
    }
}

// MARK: - AddNewPillDelegate
extension EditMyPillViewController: AddNewPillDelegate {
    func didAddPill(_ pill: Pill) {
        delegate?.didAddPill(pill)
        
        if let existingUser  = userStore.fetchUser () {
            let myPillsViewController = MyPillsViewController(userName: existingUser .name)

            navigationController?.setViewControllers([myPillsViewController], animated: true)
        } else {
            print("Пользователь не найден.")
        }
    }
}
