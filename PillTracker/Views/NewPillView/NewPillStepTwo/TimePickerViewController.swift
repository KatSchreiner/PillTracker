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
        doneButton.setTitle("Готово", for: .normal)
        doneButton.backgroundColor = .lBlue
        doneButton.titleLabel?.textColor = .white
        doneButton.tintColor = .white
        doneButton.layer.cornerRadius = 8
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        return doneButton
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
        
        dismiss(animated: true, completion: nil)
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16

        [timePicker, doneButton].forEach { view.addSubview($0) }
        
        addConstraints()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            timePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            
            doneButton.topAnchor.constraint(equalTo: timePicker.bottomAnchor, constant: 10),
            doneButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
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
