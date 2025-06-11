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
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        return stackView
    }()
    
    lazy var nextButton: UIButton = createControlButton(title: "Далее", action: #selector(goToNextStep))
    private lazy var backButton: UIButton = createControlButton(title: "Назад", action: #selector(goToPreviousStep))
    lazy var doneButton: UIButton = createControlButton(title: "Готово", action: #selector(didTapDoneButton))
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
        doneButton.animatePress()
        moveToStepThree()
        let pill = createPill()
        delegate?.didAddPill(pill)
        printPillDetails(pill)
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func didTapCancelButton() {
        cancelButton.animatePress()
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func goToNextStep() {
        nextButton.animatePress()
        
        guard let currentIndex = AddPillStep.allCases.firstIndex(of: currentStep), currentIndex < AddPillStep.allCases.count - 1 else { return }
        
        updateCurrentStep(to: currentIndex + 1)
    }
    
    @objc
    private func goToPreviousStep() {
        backButton.animatePress()
        
        guard let currentIndex = AddPillStep.allCases.firstIndex(of: currentStep), currentIndex > 0 else { return }
        
        updateCurrentStep(to: currentIndex - 1)
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .systemBackground
        setupNavigation()
        
        [progressView, containerView, buttonStackView].forEach { [weak self] view in
            guard let self = self else { return }
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        configureButtons()
        addConstraint()
        updateProgress()
    }
    
    private func setupNavigation() {
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
            
            buttonStackView.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func configureButtons() {
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(backButton)
        buttonStackView.addArrangedSubview(nextButton)
        buttonStackView.addArrangedSubview(doneButton)
        
        cancelButton.isHidden = true
        backButton.isHidden = true
        nextButton.isHidden = true
        doneButton.isHidden = true
    }
    
    private func createControlButton(title: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.backgroundColor = title == "Далее" || title == "Назад" ? .lBlue : .dBlue
        button.layer.cornerRadius = 8
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func updateCurrentStep(to newIndex: Int) {
        switch currentStep {
        case .stepOne:
            moveToStepOne()
        case .stepTwo:
            moveToStepTwo()
        case .stepThree:
            moveToStepThree()
        }
        
        let isMovingForward = newIndex > AddPillStep.allCases.firstIndex(of: currentStep)!
        currentStep = AddPillStep.allCases[newIndex]
        showStepViewController(for: currentStep, isMovingForward: isMovingForward)
        updateProgress()
    }
    
    private func moveToStepOne() {
        guard let stepOneVC = currentChildVC as? NewPillStepOneViewController else { return }
        pillStepOneModel.title = stepOneVC.titleTextField.text
        
        if let dosageText = stepOneVC.dosageTextField.text, let dosageValue = Double(dosageText) {
            pillStepOneModel.dosage = dosageValue
        } else {
            pillStepOneModel.dosage = nil
        }
        pillStepOneModel.selectedIcon = stepOneVC.formTypesButton.image(for: .normal)
        pillStepOneModel.selectedUnit = stepOneVC.selectedUnit
    }
    
    private func moveToStepTwo() {
        guard let stepTwoVC = currentChildVC as? NewPillStepTwoViewController else { return }
        stepTwoVC.updateSelectedTimes()
        pillStepTwoModel.selectedTimes = stepTwoVC.selectedTimes
        pillStepTwoModel.selectedIcon = stepTwoVC.model?.selectedIcon
        pillStepTwoModel.selectedOption = stepTwoVC.model?.selectedOption
        
        stepTwoVC.selectedTimes = pillStepTwoModel.selectedTimes
        stepTwoVC.selectedOption = pillStepTwoModel.selectedOption
    }
    
    private func moveToStepThree() {
        guard let stepThreeVC = currentChildVC as? NewPillStepThreeViewController else { return }
        pillStepThreeModel.selectedDays = stepThreeVC.model.selectedDays
        pillStepThreeModel.startDate = stepThreeVC.model.startDate
        pillStepThreeModel.endDate = stepThreeVC.model.endDate
        pillStepThreeModel.isReminderEnabled = stepThreeVC.model.isReminderEnabled
    }
    
    private func createPill() -> Pill {
        let formattedUnitTitle = String.getUnitTitle(
            for: pillStepOneModel.dosage ?? 0.0,
            unit: pillStepOneModel.selectedUnit ?? ""
        )
        return Pill(
            id: UUID(),
            icon: pillStepOneModel.selectedIcon,
            name: pillStepOneModel.title ?? "",
            dosage: pillStepOneModel.dosage ?? 0.0,
            unit: formattedUnitTitle,
            howToTake: pillStepTwoModel.selectedOption ?? "",
            times: pillStepTwoModel.selectedTimes,
            selectedDays: pillStepThreeModel.selectedDays,
            selectedStartDate: pillStepThreeModel.startDate ?? Date(),
            selectedEndDate: pillStepThreeModel.endDate ?? Date()
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
        print("Напомнить: \(pillStepThreeModel.isReminderEnabled)")
        
        if let stepThreeVC = currentChildVC as? NewPillStepThreeViewController {
            print("Начало лечения: \(stepThreeVC.formattedStartDate())")
            print("Окончание лечения: \(stepThreeVC.formattedEndDate())")
        } else {
            print("Начало лечения: \(String(describing: pillStepThreeModel.startDate))")
            print("Окончание лечения: \(String(describing: pillStepThreeModel.endDate))")
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
            stepTwo.model = pillStepTwoModel
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
    
    private func updateControlsButton() {
        cancelButton.isHidden = true
        backButton.isHidden = true
        nextButton.isHidden = true
        doneButton.isHidden = true
        
        switch currentStep {
        case .stepOne:
            cancelButton.isHidden = false
            nextButton.isHidden = false
            
            nextButton.isEnabled = pillStepOneModel.isValid()
            nextButton.alpha = nextButton.isEnabled ? 1.0 : 0.5
            
        case .stepTwo:
            backButton.isHidden = false
            nextButton.isHidden = false
            
            nextButton.isEnabled = pillStepTwoModel.isValid()
            nextButton.alpha = nextButton.isEnabled ? 1.0 : 0.5
            
        case .stepThree:
            backButton.isHidden = false
            doneButton.isHidden = false
            
            doneButton.isEnabled = pillStepThreeModel.isValid()
            doneButton.alpha = doneButton.isEnabled ? 1.0 : 0.5
        }
        
        UIView.transition(with: buttonStackView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.buttonStackView.layoutIfNeeded()
        }, completion: nil)
    }
    
    func updateProgress() {
        let progress = Float(currentStep.rawValue + 1) / Float(AddPillStep.allCases.count)
        progressView.setProgress(progress, animated: true)
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
}
