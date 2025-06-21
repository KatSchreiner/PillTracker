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
    private let addNewPillVC: AddNewPillViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    init(addNewPillVC: AddNewPillViewController) {
        self.addNewPillVC = addNewPillVC
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        addNewPillVC.delegate = self
        
        guard let pill = pill else { return }
        
        configurePillData(with: pill)
        
        addChild(addNewPillVC)
        view.addSubview(addNewPillVC.view)
        addNewPillVC.view.frame = view.bounds
        addNewPillVC.didMove(toParent: self)
    }
    
    private func configurePillData(with pill: Pill) {
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
}

// MARK: - AddNewPillDelegate
extension EditMyPillViewController: AddNewPillDelegate {
    func didAddPill(_ pill: Pill) {
        delegate?.didAddPill(pill)
        
        guard let existingUser  = userStore.fetchUser () else {
            print("Пользователь не найден.")
            return
        }
        
        let myPillsViewController = MyPillsViewController(userName: existingUser .name)
        navigationController?.setViewControllers([myPillsViewController], animated: true)
    }
}
