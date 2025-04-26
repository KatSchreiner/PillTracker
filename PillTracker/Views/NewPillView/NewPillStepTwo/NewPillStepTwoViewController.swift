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
    
    var model: PillStepTwoModel?
    
    var selectedTimes: [(hour: String, minute: String)] = []
    
    var selectedOption: String?
    let optionData = ["До еды", "Во время еды", "После еды", "Не важно"]
    let optionImages = [
        UIImage(named: "beforeEat")?.withRenderingMode(.alwaysOriginal),
        UIImage(named: "duringEat")?.withRenderingMode(.alwaysOriginal),
        UIImage(named: "afterEat")?.withRenderingMode(.alwaysOriginal),
        UIImage(named: "beforeEat")?.withRenderingMode(.alwaysOriginal)
    ]
    let optionImagesColor = [
        UIImage(named: "beforeEatColor")?.withRenderingMode(.alwaysOriginal),
        UIImage(named: "duringEatColor")?.withRenderingMode(.alwaysOriginal),
        UIImage(named: "afterEatColor")?.withRenderingMode(.alwaysOriginal),
        UIImage(named: "beforeEatColor")?.withRenderingMode(.alwaysOriginal)
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
            let button = UIButton(type: .custom)
            button.setTitle(option, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            button.setTitleColor(.dGray, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
            button.layer.cornerRadius = 8
            button.layer.masksToBounds = true
            
            button.adjustsImageWhenHighlighted = false
            
            if let image = optionImages[index] {
                button.setImage(image, for: .normal)
                button.imageView?.contentMode = .scaleAspectFit
            }
            
            let label = UILabel()
            label.text = option
            label.font = UIFont.systemFont(ofSize: 10)
            label.textColor = .dGray
            label.textAlignment = .center
            
            let buttonContainer = UIStackView(arrangedSubviews: [button, label])
            buttonContainer.axis = .vertical
            buttonContainer.spacing = 4
            buttonContainer.alignment = .center
            
            stackView.addArrangedSubview(buttonContainer)
        }
        
        return stackView
    }()

    private var timeLabels: [UILabel] = []
    private var addTimePickerButtonTopConstraint: NSLayoutConstraint!
    
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
        
        let viewToRemove = timeStackView.arrangedSubviews[index]
        
        UIView.animate(withDuration: 0.3, animations: {
            viewToRemove.alpha = 0
        }) { _ in
            self.timeLabels[index].removeFromSuperview()
            self.timeLabels.remove(at: index)
            viewToRemove.removeFromSuperview()
            
            for i in index..<self.timeStackView.arrangedSubviews.count {
                if let button = self.timeStackView.arrangedSubviews[i].subviews.last as? UIButton {
                    button.tag = i
                }
            }
            self.updateSelectedTimes()
            self.updateNextButtonStateStepTwo()
        }
    }
    
    @objc
    private func optionButtonTapped(_ sender: UIButton) {
        selectedOption = optionData[sender.tag]
        
        model?.selectedOption = selectedOption
        model?.selectedIcon = optionImagesColor[sender.tag]
                
        for (index, subview) in buttonStackView.arrangedSubviews.enumerated() {
            if let buttonContainer = subview as? UIStackView,
               let button = buttonContainer.arrangedSubviews.first as? UIButton {
                
                if index == sender.tag {
                    UIView.transition(with: button, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        button.animatePress()
                        button.setImage(self.optionImagesColor[index], for: .normal)
                    })
                } else {
                    UIView.transition(with: button, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        button.setImage(self.optionImages[index], for: .normal)
                    }, completion: nil)
                }
            }
        }
        updateNextButtonStateStepTwo()
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
        
        [buttonStackView, timePickerLabel, timeStackView, addTimePickerButton].forEach { view in
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            timePickerLabel.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 60),
            timePickerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
    
            timeStackView.topAnchor.constraint(equalTo: timePickerLabel.bottomAnchor, constant: 20),
            timeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            timeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            addTimePickerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            addTimePickerButton.widthAnchor.constraint(equalToConstant: 40),
            addTimePickerButton.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        addTimePickerButtonTopConstraint = addTimePickerButton.topAnchor.constraint(equalTo: timeStackView.bottomAnchor)
        addTimePickerButtonTopConstraint.isActive = true
    }
    
    private func loadData() {
        if let selectedOption = model?.selectedOption, let index = optionData.firstIndex(of: selectedOption) {
            
            for (i, subview) in buttonStackView.arrangedSubviews.enumerated() {
                if let buttonContainer = subview as? UIStackView,
                   let button = buttonContainer.arrangedSubviews.first as? UIButton {
                    if i == index {
                        button.setImage(optionImagesColor[i], for: .normal)
                    } else {
                        button.setImage(optionImages[i], for: .normal)
                    }
                }
            }
        }
        
        timeLabels.forEach { $0.removeFromSuperview() }
        timeLabels.removeAll()
        for time in model?.selectedTimes ?? [] {
            let timeLabel = UILabel()
            timeLabel.text = "\(time.hour):\(time.minute)"
            timeLabel.font = UIFont.systemFont(ofSize: 18)
            timeLabel.textColor = .dGray
            timeLabel.textAlignment = .center
            timeLabel.backgroundColor = .lGray
            timeLabel.layer.cornerRadius = 8
            timeLabel.layer.masksToBounds = true
            timeLabel.translatesAutoresizingMaskIntoConstraints = false
            
            timeLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
            
            let removeButton = UIButton(type: .system)
            removeButton.setImage(UIImage(systemName: "minus"), for: .normal)
            removeButton.tintColor = .dGray
            removeButton.addTarget(self, action: #selector(didTapRemoveTimePicker(_:)), for: .touchUpInside)
            removeButton.tag = timeLabels.count;
            
            let timeContainer = UIStackView(arrangedSubviews: [timeLabel, removeButton])
            timeContainer.axis = .horizontal
            timeContainer.spacing = 15
            timeContainer.translatesAutoresizingMaskIntoConstraints = false
            
            timeStackView.addArrangedSubview(timeContainer)
            timeLabels.append(timeLabel)
            
            addTimePickerButtonTopConstraint.constant = 20
            
        }
    }
    
    func updateNextButtonStateStepTwo() {
        model?.selectedTimes = selectedTimes
        model?.selectedOption = selectedOption

        let isEnabled = model?.isValid() ?? false

        if let addNewPillView = parent as? AddNewPillViewController {
            addNewPillView.nextButton.isEnabled = isEnabled
            addNewPillView.nextButton.alpha = isEnabled ? 1.0 : 0.5
        }
    }
}

extension NewPillStepTwoViewController: TimePickerDelegate {
    func didSelectTime(selectedTime: String) {
        let timeLabel = UILabel()
        timeLabel.text = selectedTime
        timeLabel.font = UIFont.systemFont(ofSize: 18)
        timeLabel.textColor = .dGray
        timeLabel.textAlignment = .center
        timeLabel.backgroundColor = .lGray
        timeLabel.layer.cornerRadius = 8
        timeLabel.layer.masksToBounds = true
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        timeLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let removeButton = UIButton(type: .system)
        removeButton.setImage(UIImage(systemName: "minus"), for: .normal)
        removeButton.tintColor = .dGray
        removeButton.addTarget(self, action: #selector(didTapRemoveTimePicker(_:)), for: .touchUpInside)
        removeButton.tag = timeLabels.count
        
        let timeContainer = UIStackView(arrangedSubviews: [timeLabel, removeButton])
        timeContainer.axis = .horizontal
        timeContainer.spacing = 15
        timeContainer.translatesAutoresizingMaskIntoConstraints = false
        
        timeStackView.addArrangedSubview(timeContainer)
        timeLabels.append(timeLabel)
        
        updateSelectedTimes()
        
        addTimePickerButtonTopConstraint.constant = 20
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        updateNextButtonStateStepTwo()
    }
}
