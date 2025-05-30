//
//  TimePickerAlert.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 10.04.2025.
//

import UIKit

protocol TimePickerDelegate: AnyObject {
    func didSelectTime(selectedTime: String)
}

class TimePickerViewController: UIViewController {
    weak var delegate: TimePickerDelegate?
    
    private lazy var timePicker: UIDatePicker = {
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        return timePicker
    }()
    
    private lazy var doneButton: UIButton = {
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Добавить", for: .normal)
        doneButton.backgroundColor = .lBlue
        doneButton.titleLabel?.textColor = .white
        doneButton.tintColor = .white
        doneButton.layer.cornerRadius = 8
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        return doneButton
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Закрыть", for: .normal)
        cancelButton.backgroundColor = .dBlue
        cancelButton.titleLabel?.textColor = .white
        cancelButton.tintColor = .white
        cancelButton.layer.cornerRadius = 8
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        return cancelButton
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, doneButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @objc
    private func didTapDoneButton() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let selectedTime = dateFormatter.string(from: timePicker.date)
        
        delegate?.didSelectTime(selectedTime: selectedTime)
    }
    
    @objc
    private func didTapCancelButton() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16

        [timePicker, buttonStackView].forEach { view.addSubview($0) }
        
        addConstraints()
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
