//
//  TimePickerAlert.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 10.04.2025.
//

import UIKit

protocol TimePickerDelegate: AnyObject {
    func didSelectTime(selectedTime: String)
    func didUpdateTime(selectedTime: String, at index: Int)
}

final class TimePickerViewController: UIViewController {
    // MARK: - Public Properties
    weak var delegate: TimePickerDelegate?
    
    var editingIndex: Int?
    
    // MARK: - Private Properties
    lazy var timePicker: UIDatePicker = {
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.minuteInterval = 5
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        return timePicker
    }()
    
    private lazy var doneButton: UIButton = {
        return CustomButton.makeButton(
            title: "Добавить",
            titleColor: .white,
            backgroundColor: .lBlue,
            cornerRadius: Constants.defaultRadius,
            contentEdgeInsets: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20),
            target: self,
            action: #selector(didTapDoneButton)
        )
    }()

    private lazy var cancelButton: UIButton = {
        return CustomButton.makeButton(
            title: "Закрыть",
            titleColor: .white,
            backgroundColor: .dBlue,
            cornerRadius: Constants.defaultRadius,
            contentEdgeInsets: UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20),
            target: self,
            action: #selector(didTapCancelButton)
        )
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, doneButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - IB Actions
    @objc
    private func didTapDoneButton() {
        doneButton.animatePress(duration: 0.2)
        
        let selectedTime = timeFormatter.string(from: timePicker.date)
        let components = selectedTime.components(separatedBy: ":")
        guard components.count == 2 else { return }
        
        if let index = editingIndex {
            delegate?.didUpdateTime(selectedTime: selectedTime, at: index)
            dismiss(animated: true)
        } else {
            delegate?.didSelectTime(selectedTime: selectedTime)
        }
        
    }
    
    @objc
    private func didTapCancelButton() {
        cancelButton.animatePress(duration: 0.2)
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Public Methods
    func setSpecificTime(hour: String, minute: String) {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.hour = Int(hour)
        dateComponents.minute = Int(minute)
       
        if let date = calendar.date(from: dateComponents) {
            timePicker.setDate(date, animated: false)
        } else {
            timePicker.setDate(Date(), animated: false)
        }
    }
    
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16

        [timePicker, buttonStackView].forEach { view.addSubview($0) }
        addConstraints()
        updateButtonTitle()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            timePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            
            buttonStackView.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 10),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60) 
        ])
    }
    
    private func updateButtonTitle() {
        let title = editingIndex != nil ? "Изменить" : "Добавить"
        doneButton.setTitle(title, for: .normal)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension TimePickerViewController: UIViewControllerTransitioningDelegate {
    func presentAsBottomSheet(on parent: UIViewController) {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        
        parent.present(self, animated: true, completion: nil)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
