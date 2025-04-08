//
//  AddNewPillViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 07.04.2025.
//

import UIKit

protocol AddNewPillDelegate: AnyObject {
    func didAddPill(_ pill: Pill)
}

final class AddNewPillViewController: UIViewController {
    
    // MARK: - Public Properties
    var pillStepOneModel = PillStepOneModel()
    var pillStepTwoModel = PillStepTwoModel()
    var pillStepThreeModel = PillStepThreeModel()
    
    weak var delegate: AddNewPillDelegate?
    
    // MARK: - Private Properties
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = .lBlue
        progressView.trackTintColor = .lGray
        return progressView
    }()
    
    private lazy var containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .clear
        return container
    }()
    
    lazy var nextButton: UIButton = createControlButton(title: "Далее", action: #selector(goToNextStep))
    private lazy var backButton: UIButton = createControlButton(title: "Назад", action: #selector(goToPreviousStep))
    private lazy var doneButton: UIButton = createControlButton(title: "Готово", action: #selector(didTapDoneButton))
    private lazy var cancelButton: UIButton = createControlButton(title: "Отмена", action: #selector(didTapCancelButton))
    
    private var currentStep: AddPillStep = .stepOne
    private var currentChildVC: UIViewController?
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        showStepViewController(for: currentStep, isMovingForward: true)
    }
    
    // MARK: - IB Actions
    @objc
    private func didTapDoneButton() {
        moveToStepThree()
        
        let pill = Pill(
            id: UUID(),
            icon: pillStepOneModel.selectedIcon,
            name: pillStepOneModel.title ?? "",
            dosage: Int(pillStepOneModel.dosage ?? "") ?? 0,
            unit: pillStepOneModel.selectedUnit ?? "",
            howToTake: pillStepTwoModel.selectedOption ?? "",
            times: pillStepTwoModel.selectedTimes,
            selectedDays: pillStepThreeModel.selectedDays
        )
        
        delegate?.didAddPill(pill)
        
        print("Данные переданы:")
        print("ID лекарства: \(pill.id)")
        print("Иконка: \(pillStepOneModel.selectedIcon?.description ?? "nil")")
        print("Название лекарства: \(pillStepOneModel.title ?? "nil")")
        print("Дозировка: \(pillStepOneModel.dosage ?? "nil")")
        print("Единица измерения: \(pillStepOneModel.selectedUnit ?? "nil")")
        
        print("Время приема: \(String(describing: pillStepTwoModel.selectedTimes))")
        print("Как принимать: \(pillStepTwoModel.selectedOption ?? "nil")")
        
        print("Выбранные дни: \(pillStepThreeModel.selectedDays)")
        print("Напомнить: \(pillStepThreeModel.isReminderEnabled)")
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func didTapCancelButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func goToPreviousStep() {
        guard let currentIndex = AddPillStep.allCases.firstIndex(of: currentStep), currentIndex > 0 else { return }
        
        currentStep = AddPillStep.allCases[currentIndex - 1]
        showStepViewController(for: currentStep, isMovingForward: false)
        updateProgress()
    }
    
    @objc
    private func goToNextStep() {
        guard let currentIndex = AddPillStep.allCases.firstIndex(of: currentStep),
              currentIndex < AddPillStep.allCases.count - 1 else { return }
        
        if currentStep == .stepOne {
            moveToStepOne()
        } else if currentStep == .stepTwo {
            moveToStepTwo()
        }
        
        currentStep = AddPillStep.allCases[currentIndex + 1]
        showStepViewController(for: currentStep, isMovingForward: true)
        updateProgress()
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        setupNavigation()

        nextButton.isEnabled = false
        nextButton.alpha = 0.5
        
        [progressView, containerView, backButton, nextButton, cancelButton, doneButton].forEach { [weak self] view in
            guard let self = self else { return }
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }

        addConstraint()
        updateProgress()
    }
    
    func setupNavigation() {
        navigationItem.setHidesBackButton(true, animated: false)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func addConstraint() {
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            containerView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 150),
            backButton.heightAnchor.constraint(equalToConstant: 60),

            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.widthAnchor.constraint(equalToConstant: 150),
            nextButton.heightAnchor.constraint(equalToConstant: 60),

            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalToConstant: 150),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.widthAnchor.constraint(equalToConstant: 150),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func createControlButton(title: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.backgroundColor = title == "Далее" || title == "Назад" ? .lBlue : .dBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    func moveToStepOne() {
        if let stepOneVC = currentChildVC as? NewPillStepOneViewController {
            pillStepOneModel.title = stepOneVC.titleTextField.text
            pillStepOneModel.dosage = stepOneVC.dosageTextField.text
            pillStepOneModel.selectedIcon = stepOneVC.formTypesButton.image(for: .normal)
            let selectedRow = stepOneVC.unitPickerView.selectedRow(inComponent: 0)
            pillStepOneModel.selectedUnit = stepOneVC.unitPickerViewData[selectedRow]
        }
    }
    
    func moveToStepTwo() {
        if let stepTwoVC = currentChildVC as? NewPillStepTwoViewController {
            stepTwoVC.updateSelectedTimes()
            pillStepTwoModel.selectedTimes = stepTwoVC.selectedTimes
            let selectedRow = stepTwoVC.pickerView.selectedRow(inComponent: 0)
            pillStepTwoModel.selectedOption = stepTwoVC.pickerData[selectedRow]
        }
    }
    
    func moveToStepThree() {
        if let stepThreeVC = currentChildVC as? NewPillStepThreeViewController {
            pillStepThreeModel.selectedDays = stepThreeVC.model.selectedDays
            pillStepThreeModel.isReminderEnabled = stepThreeVC.model.isReminderEnabled
        }
    }
}

// MARK: - Step Management
private extension AddNewPillViewController {
    func showStepViewController(for step: AddPillStep, isMovingForward: Bool) {
        let newPillView: UIViewController
        
        switch step {
        case .stepOne:
            let stepOne = NewPillStepOneViewController()
            stepOne.pillStepOneModel = pillStepOneModel
            newPillView = stepOne
        case .stepTwo:
            let stepTwo = NewPillStepTwoViewController()
            stepTwo.pillStepTwoModel = pillStepTwoModel
            newPillView = stepTwo
        case .stepThree:
            let stepThree = NewPillStepThreeViewController()
            stepThree.model = pillStepThreeModel
            newPillView = stepThree
        }
        
        addContainerStepView(basicView: newPillView, isMovingForward: isMovingForward)
    }
    
    func addContainerStepView(basicView: UIViewController, isMovingForward: Bool) {
        addChild(basicView)
        containerView.addSubview(basicView.view)
        basicView.view.frame = containerView.bounds
        
        if isMovingForward {
            basicView.view.transform = CGAffineTransform(translationX: containerView.bounds.width, y: 0)
        } else {
            basicView.view.transform = CGAffineTransform(translationX: -containerView.bounds.width, y: 0)
        }
        
        basicView.didMove(toParent: self)
        
        UIView.animate(withDuration: 0.5, animations: {
            basicView.view.transform = .identity
        }) { _ in
            self.currentChildVC?.willMove(toParent: nil)
            self.currentChildVC?.view.removeFromSuperview()
            self.currentChildVC?.removeFromParent()
            self.currentChildVC = basicView
            
            self.updateControlsButton()
        }
    }
    
    func updateControlsButton() {
        backButton.isHidden = currentStep == .stepOne
        nextButton.isHidden = currentStep == .stepThree
        cancelButton.isHidden = currentStep != .stepOne
        doneButton.isHidden = currentStep != .stepThree
    }
    
    func updateProgress() {
        let progress = Float(currentStep.rawValue + 1) / Float(AddPillStep.allCases.count)
        progressView.setProgress(progress, animated: true)
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
}
