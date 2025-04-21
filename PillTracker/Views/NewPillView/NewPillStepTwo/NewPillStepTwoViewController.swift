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
    let optionData = ["До еды", "Во время еды", "После еды", "Не важно"]
    let optionImages = [
        UIImage(named: "beforeEat"),
        UIImage(named: "duringEat"),
        UIImage(named: "afterEat"),
        UIImage(named: "beforeEat")
    ]
    
    // MARK: - Private Properties
    private lazy var timePickerLabel: UILabel = {
        let label = UILabel()
        label.text = "Время приема"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18)
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
        button.tintColor = .dGray
        button.backgroundColor = .lGray
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(didTapAddTimePicker), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        
        for (index, option) in optionData.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(option, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            button.setTitleColor(.dGray, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
            button.layer.cornerRadius = 8
            button.layer.masksToBounds = true
            
            if let image = optionImages[index] {
                button.setImage(image, for: .normal)
                button.imageView?.contentMode = .scaleAspectFit
            }
            
            stackView.addArrangedSubview(button)
        }
        
        return stackView
    }()
    

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
        addTimePickerButton.animatePress()
        
        let timePickerView = TimePickerViewController()
        timePickerView.delegate = self
        timePickerView.presentAsBottomSheet(on: self)
    }
    
    @objc
    private func didTapRemoveTimePicker(_ sender: UIButton) {
        let index = sender.tag
        
        guard index < timeLabels.count, index < timeStackView.arrangedSubviews.count else {
            return
        }
        
        timeLabels[index].removeFromSuperview()
        timeLabels.remove(at: index)
        timeStackView.arrangedSubviews[index].removeFromSuperview()
        
        for i in index..<timeStackView.arrangedSubviews.count {
            if let button = timeStackView.arrangedSubviews[i].subviews.last as? UIButton {
                button.tag = i
            }
        }
    }
    
    @objc
    private func optionButtonTapped(_ sender: UIButton) {
        selectedOption = optionData[sender.tag]
        pillStepTwoModel?.selectedOption = selectedOption
        
        for subview in sender.superview?.subviews ?? [] {
            if let button = subview as? UIButton {
                button.setTitleColor(.dGray, for: .normal)
            }
        }
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
        
        [buttonStackView, timePickerLabel, addTimePickerButton, timeStackView].forEach { view in
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            addTimePickerButton.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 50),
            addTimePickerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addTimePickerButton.widthAnchor.constraint(equalToConstant: 60),
            addTimePickerButton.heightAnchor.constraint(equalToConstant: 60),
            
            timePickerLabel.topAnchor.constraint(equalTo: addTimePickerButton.bottomAnchor, constant: 20),
            timePickerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            timeStackView.topAnchor.constraint(equalTo: addTimePickerButton.bottomAnchor, constant: 20),
            timeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func loadData() {
        if let selectedOption = pillStepTwoModel?.selectedOption, let index = optionData.firstIndex(of: selectedOption) {
            if let button = buttonStackView.arrangedSubviews[index] as? UIButton {
                button.setTitleColor(.dBlue, for: .normal)
            }
        }
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
