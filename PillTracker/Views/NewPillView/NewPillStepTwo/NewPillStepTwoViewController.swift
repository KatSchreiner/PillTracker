//
//  NewPillStepTwoViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 07.04.2025.
//

import UIKit

class NewPillStepTwoViewController: UIViewController {
    // MARK: - Public Properties
    static var stepTwo = "NewPillStepTwoCell"
    
    var pillStepTwoModel: PillStepTwoModel?
    
    var selectedTimes: [(hour: String, minute: String)] = []
    
    var selectedOption: String?
    let pickerData = ["Не зависит от еды", "До еды", "Во время еды", "После еды"]

    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    
    // MARK: - Private Properties
    private lazy var timePickerLabel: UILabel = {
        let label = UILabel()
        label.text = "Время приема"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .dGray
        return label
    }()
    
    private lazy var addTimePickerButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .lRed
        button.addTarget(self, action: #selector(didTapAddTimePicker), for: .touchUpInside)
        return button
    }()
    
    private var pickerViewTopConstraint: NSLayoutConstraint?
    private var timePickers: [CustomTimePicker] = []
    private var removeButtons: [UIButton] = []
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadData()
        addNewTimePicker()
    }

    // MARK: - IB Actions
    @objc
    private func didTapAddTimePicker() {
        addNewTimePicker()
    }
    
    @objc
    private func didTapRemoveTimePicker(_ sender: UIButton) {
        guard let index = removeButtons.firstIndex(of: sender) else { return }

        let timePickerToRemove = timePickers[index]
        timePickers.remove(at: index)
        removeButtons.remove(at: index)
              
        if index < selectedTimes.count {
            selectedTimes.remove(at: index)
        }
        
        timePickerToRemove.removeFromSuperview()
        sender.removeFromSuperview()
        
        updateConstraintsAfterRemoval()
        
        if timePickers.count < 2 {
            sender.isHidden = true
        }
    }
    
    // MARK: - Public Methods
    
    func updateSelectedTimes() {
        selectedTimes.removeAll()
        for picker in timePickers {
            let hour = picker.hours[picker.selectedRow(inComponent: 0)]
            let minute = picker.minutes[picker.selectedRow(inComponent: 2)]
            selectedTimes.append((hour: hour, minute: minute))
        }
    }
    
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .white
        
        [timePickerLabel, addTimePickerButton, pickerView].forEach { view in
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addInitialConstraints()
    }
    
    private func addInitialConstraints() {
        NSLayoutConstraint.activate([
            timePickerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timePickerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            addTimePickerButton.centerYAnchor.constraint(equalTo: timePickerLabel.centerYAnchor),
            addTimePickerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        pickerViewTopConstraint = pickerView.topAnchor.constraint(equalTo: addTimePickerButton.bottomAnchor)
        pickerViewTopConstraint?.isActive = true
        
        pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
    }
    
    private func addNewTimePicker() {
        let newTimePicker = CustomTimePicker()
        newTimePicker.timePickerDelegate = self
        timePickers.append(newTimePicker)
        
        view.addSubview(newTimePicker)
        newTimePicker.translatesAutoresizingMaskIntoConstraints = false
        
        let removeButton = UIButton(type: .system)
        removeButton.setImage(UIImage(systemName: "minus"), for: .normal)
        removeButton.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        removeButton.tintColor = .lRed
        removeButton.addTarget(self, action: #selector(didTapRemoveTimePicker(_:)), for: .touchUpInside)
        view.addSubview(removeButton)
        removeButtons.append(removeButton)
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        
        let lastPicker: CustomTimePicker? = timePickers.count > 1 ? timePickers[timePickers.count - 2] : nil
        
        NSLayoutConstraint.activate([
            newTimePicker.topAnchor.constraint(equalTo: lastPicker?.bottomAnchor ?? addTimePickerButton.bottomAnchor, constant: 20),
            newTimePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newTimePicker.heightAnchor.constraint(equalToConstant: 60),
            newTimePicker.widthAnchor.constraint(equalToConstant: 180),
            
            removeButton.centerYAnchor.constraint(equalTo: newTimePicker.centerYAnchor),
            removeButton.leadingAnchor.constraint(equalTo: newTimePicker.trailingAnchor, constant: 10)
        ])

        updatePickerViewConstraint()
        
        removeButton.isHidden = timePickers.count < 2
    }

    private func updatePickerViewConstraint() {
        pickerViewTopConstraint?.isActive = false
        
        if let lastPicker = timePickers.last {
            pickerViewTopConstraint = pickerView.topAnchor.constraint(equalTo: lastPicker.bottomAnchor)
            pickerViewTopConstraint?.isActive = true
        }
        
        view.layoutIfNeeded()
    }
    
    private func updateConstraintsAfterRemoval() {
        for (index, timePicker) in timePickers.enumerated() {
            let previousPicker: CustomTimePicker? = index > 0 ? timePickers[index - 1] : nil
            
            NSLayoutConstraint.activate([
                timePicker.topAnchor.constraint(equalTo: previousPicker?.bottomAnchor ?? addTimePickerButton.bottomAnchor, constant: 20)
            ])
        }
        updatePickerViewConstraint()
    }
    
    private func loadData() {
        
        if let selectedOption = pillStepTwoModel?.selectedOption, let index = pickerData.firstIndex(of: selectedOption) {
            pickerView.selectRow(index, inComponent: 0, animated: false)
        }
    }
}

// MARK: - UIPickerViewDataSource
extension NewPillStepTwoViewController: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .dGray
        label.textAlignment = .center
        label.text = pickerData[row]
        return label
    }
}

// MARK: - UIPickerViewDelegate
extension NewPillStepTwoViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedOption = pickerData[row]
        pillStepTwoModel?.selectedOption = selectedOption
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
}

// MARK: - UIPickerViewDelegate
extension NewPillStepTwoViewController: CustomTimePickerDelegate {
    func didPickTime(hour: String, minute: String) {
        selectedTimes.append((hour: hour, minute: minute))
    }
}
