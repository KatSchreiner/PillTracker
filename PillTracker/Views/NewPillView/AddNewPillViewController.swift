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
    
    // MARK: - Properties
    let viewModel: AddNewPillViewModel
    weak var delegate: AddNewPillDelegate?
    
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
        stackView.spacing = Constants.defaultPadding
        return stackView
    }()
    
    lazy var nextButton: UIButton = createControlButton(title: "Далее", action: #selector(goToNextStep))
    private lazy var backButton: UIButton = createControlButton(title: "Назад", action: #selector(goToPreviousStep))
    lazy var doneButton: UIButton = createControlButton(title: "Готово", action: #selector(didTapDoneButton))
    private lazy var cancelButton: UIButton = createControlButton(title: "Отмена", action: #selector(didTapCancelButton))
    
    var doneButtonTitle: String = "Готово" {
        didSet {
            doneButton.setTitle(doneButtonTitle, for: .normal)
        }
    }
    
    private var currentChildVC: UIViewController?
    
    // MARK: - Initialization
    init(isEditingPill: Bool = false, editedPillId: UUID? = nil) {
        self.viewModel = AddNewPillViewModel(isEditingPill: isEditingPill, editedPillId: editedPillId)
        super.init(nibName: nil, bundle: nil)
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        showStepViewController(for: viewModel.currentStep, isMovingForward: true)
    }
    
    // MARK: - Setup
    private func setupBindings() {
        viewModel.onUpdateControls = { [weak self] step in
            self?.showStepViewController(for: step, isMovingForward: true)
        }
        
        viewModel.onProgressUpdate = { [weak self] progress in
            self?.progressView.setProgress(progress, animated: true)
        }
        
        viewModel.onPillCreated = { [weak self] pill in
            self?.delegate?.didAddPill(pill)
        }
        
        viewModel.onNavigationPop = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        viewModel.onPrintDetails = { [weak self] pill in
            self?.printPillDetails(pill)
        }
    }
    
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
        viewModel.updateProgress()
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
    
    // MARK: - Button Actions
    @objc private func didTapDoneButton() {
        doneButton.animatePress()
        viewModel.didTapDoneButton()
    }
    
    @objc private func didTapCancelButton() {
        cancelButton.animatePress()
        viewModel.didTapCancelButton()
    }
    
    @objc private func goToNextStep() {
        nextButton.animatePress()
        viewModel.goToNextStep()
    }
    
    @objc private func goToPreviousStep() {
        backButton.animatePress()
        viewModel.goToPreviousStep()
    }
    
    @objc private func handleTap() {
        view.endEditing(true)
    }
    
    // MARK: - Private Methods
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
    
    private func printPillDetails(_ pill: Pill) {
        print("Данные переданы:")
        print("ID лекарства: \(pill.id)")
        print("Иконка: \(viewModel.pillStepOneModel.selectedIcon?.description ?? "nil")")
        print("Название лекарства: \(viewModel.pillStepOneModel.title ?? "nil")")
        print("Дозировка: \(viewModel.pillStepOneModel.dosage ?? 0.0)")
        print("Единица измерения: \(viewModel.pillStepOneModel.selectedUnit ?? "nil")")
        print("Время приема: \(String(describing: viewModel.pillStepTwoModel.selectedTimes))")
        print("Как принимать: \(viewModel.pillStepTwoModel.selectedOption ?? "nil")")
        print("Выбранные дни: \(viewModel.pillStepThreeModel.selectedDays)")
        print("Интервал: через \(String(describing: viewModel.pillStepThreeModel.interval))")
        print("Напомнить: \(viewModel.pillStepThreeModel.isReminderEnabled)")
        print("Начало лечения: \(String(describing: viewModel.pillStepThreeModel.startDate))")
        print("Окончание лечения: \(String(describing: viewModel.pillStepThreeModel.endDate))")
    }
}

// MARK: - Step Management
private extension AddNewPillViewController {
    func showStepViewController(for step: AddPillStep, isMovingForward: Bool) {
        let newPillView: UIViewController
        
        switch step {
        case .stepOne:
            let stepOne = NewPillStepOneViewController()
            stepOne.viewModel.configure(with: viewModel.pillStepOneModel)
            viewModel.currentChildVC = stepOne
            newPillView = stepOne
        case .stepTwo:
            let stepTwo = NewPillStepTwoViewController()
            stepTwo.viewModel.configure(with: viewModel.pillStepTwoModel)
            viewModel.currentChildVC = stepTwo
            newPillView = stepTwo
        case .stepThree:
            let stepThree = NewPillStepThreeViewController()
            stepThree.viewModel.configure(with: viewModel.pillStepThreeModel)
            viewModel.currentChildVC = stepThree
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
        
        switch viewModel.currentStep {
        case .stepOne:
            cancelButton.isHidden = false
            nextButton.isHidden = false
            
            nextButton.isEnabled = viewModel.pillStepOneModel.isValid()
            nextButton.alpha = nextButton.isEnabled ? 1.0 : 0.5
            
        case .stepTwo:
            backButton.isHidden = false
            nextButton.isHidden = false
            
            nextButton.isEnabled = viewModel.pillStepTwoModel.isValid()
            nextButton.alpha = nextButton.isEnabled ? 1.0 : 0.5
            
        case .stepThree:
            backButton.isHidden = false
            doneButton.isHidden = false
            
            doneButton.isEnabled = viewModel.pillStepThreeModel.isValid()
            doneButton.alpha = doneButton.isEnabled ? 1.0 : 0.5
        }
        
        UIView.transition(with: buttonStackView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.buttonStackView.layoutIfNeeded()
        }, completion: nil)
    }
}
