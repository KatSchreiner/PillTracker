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
    
    private lazy var timeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var addTimePickerButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .lRed
        button.addTarget(self, action: #selector(didTapAddTimePicker), for: .touchUpInside)
        return button
    }()
    
    private var pickerViewTopConstraint: NSLayoutConstraint?
    private var timeLabels: [UILabel] = []
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadData()
    }
    
    // MARK: - IB Actions
    @objc
    private func didTapAddTimePicker() {
        let timePickerView = TimePickerViewController()
        timePickerView.delegate = self
        timePickerView.presentAsBottomSheet(on: self)
    }
    
    @objc
    private func didTapRemoveTimePicker(_ sender: UIButton) {
        let index = sender.tag
        timeLabels[index].removeFromSuperview()
        timeLabels.remove(at: index)
        timeStackView.arrangedSubviews[index].removeFromSuperview()
    }
    
    // MARK: - Public Methods
    
    func updateSelectedTimes() {
        selectedTimes = []
        for label in timeLabels {
            if let timeText = label.text, !timeText.isEmpty {
                let components = timeText.split(separator: ":")
                if components.count == 2 {
                    let hour = String(components[0])
                    let minute = String(components[1])
                    selectedTimes.append((hour: hour, minute: minute))
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .white
        
        [timePickerLabel, addTimePickerButton, timeStackView, pickerView].forEach { view in
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            timePickerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timePickerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            timeStackView.topAnchor.constraint(equalTo: addTimePickerButton.bottomAnchor, constant: 20),
            timeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            pickerView.topAnchor.constraint(equalTo: timeStackView.bottomAnchor, constant: 20),
            
            addTimePickerButton.centerYAnchor.constraint(equalTo: timePickerLabel.centerYAnchor),
            addTimePickerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
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

extension NewPillStepTwoViewController: TimePickerDelegate {
    func didSelectTime(selectedTime: String) {
        let timeLabel = UILabel()
        timeLabel.text = selectedTime
        timeLabel.font = UIFont.systemFont(ofSize: 20)
        timeLabel.textColor = .dGray
        timeLabel.backgroundColor = .lGray
        timeLabel.layer.cornerRadius = 8
        timeLabel.layer.masksToBounds = true
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timeLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
                
        let removeButton = UIButton(type: .system)
        removeButton.setImage(UIImage(systemName: "minus"), for: .normal)
        removeButton.tintColor = .lRed
        removeButton.addTarget(self, action: #selector(didTapRemoveTimePicker(_:)), for: .touchUpInside)
        removeButton.tag = timeLabels.count
        
        let timeContainer = UIStackView(arrangedSubviews: [timeLabel, removeButton])
        timeContainer.axis = .horizontal
        timeContainer.spacing = 10
        timeContainer.translatesAutoresizingMaskIntoConstraints = false
        
        timeStackView.addArrangedSubview(timeContainer)
        timeLabels.append(timeLabel)
        
        view.layoutIfNeeded()
    }
}
