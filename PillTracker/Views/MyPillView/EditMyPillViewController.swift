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
        addNewPillVC.viewModel.isEditingPill = true
        addNewPillVC.viewModel.editedPillId = pill.id
        
        addNewPillVC.viewModel.pillStepOneModel.title = pill.name
        addNewPillVC.viewModel.pillStepOneModel.dosage = pill.dosage
        addNewPillVC.viewModel.pillStepOneModel.selectedIcon = pill.icon
        addNewPillVC.viewModel.pillStepOneModel.selectedUnit = pill.unit
        
        addNewPillVC.viewModel.pillStepTwoModel.selectedTimes = pill.times
        addNewPillVC.viewModel.pillStepTwoModel.selectedOption = pill.howToTake
        
        addNewPillVC.viewModel.pillStepThreeModel.selectedDays = pill.selectedDays
        addNewPillVC.viewModel.pillStepThreeModel.startDate = pill.selectedStartDate
        addNewPillVC.viewModel.pillStepThreeModel.endDate = pill.selectedEndDate
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
