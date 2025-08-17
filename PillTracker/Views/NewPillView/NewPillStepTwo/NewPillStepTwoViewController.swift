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
    
    let viewModel = NewPillStepTwoViewModel()
    
    // MARK: - Private Properties
    private lazy var timePickerLabel: UILabel = {
        let label = UILabel()
        label.text = "Время приема"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .dGray
        return label
    }()
    
    private lazy var timesTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TimeCell.self, forCellReuseIdentifier: TimeCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = true
        tableView.tableFooterView = UIView()
        return tableView
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
        
        for (index, option) in viewModel.optionData.enumerated() {
            let button = UIButton(type: .custom)
            button.setTitle(option, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            button.setTitleColor(.dGray, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
            button.layer.cornerRadius = 8
            button.layer.masksToBounds = true
            
            button.adjustsImageWhenHighlighted = false
            
            if let image = viewModel.optionImages[index] {
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
    
    private var addTimePickerButtonTopConstraint: NSLayoutConstraint!
    private var timesTableViewHeightConstraint: NSLayoutConstraint!
    private var maxTimesTableHeight: CGFloat {
        return view.frame.height - (buttonStackView.frame.height + 40 + 120)
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        loadData()
    }
    
    // MARK: - IB Actions
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
    
    @objc
    private func didTapAddTimePicker() {
        addTimePickerButton.animatePress()
        
        let timePickerView = TimePickerViewController()
        timePickerView.delegate = self
        timePickerView.presentAsBottomSheet(on: self)
    }
    
    @objc
    private func didTapRemoveTimeCell(_ sender: UIButton) {
        viewModel.removeTime(at: sender.tag)
        updateSelectedTimes()
        updateNextButtonStateStepTwo()
    }
    
    // MARK: - Public Methods
    func updateSelectedTimes() {
        selectedTimes = selectedTimes.sorted { (time1, time2) -> Bool in
            if let hour1 = Int(time1.hour), let hour2 = Int(time2.hour) {
                if hour1 != hour2 {
                    return hour1 < hour2
                }
                if let minute1 = Int(time1.minute), let minute2 = Int(time2.minute) {
                    return minute1 < minute2
                }
            }
            return false
        }
        model?.selectedTimes = selectedTimes
        
        let rowCount = selectedTimes.count
        let calculatedHeight = CGFloat(rowCount * 60)
        
        timesTableViewHeightConstraint.constant = min(calculatedHeight, maxTimesTableHeight)
        timesTableView.isScrollEnabled = calculatedHeight > maxTimesTableHeight

        if rowCount > 0 {
            addTimePickerButtonTopConstraint.constant = 16
        } else {
            addTimePickerButtonTopConstraint.constant = 0
        }
        
        timesTableView.reloadData()
        view.layoutIfNeeded()
    }

    
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .white
        
        [buttonStackView, timePickerLabel, timesTableView, addTimePickerButton].forEach { view in
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
            
            timePickerLabel.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 40),
            timePickerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            
            timesTableView.topAnchor.constraint(equalTo: timePickerLabel.bottomAnchor, constant: 20),
            timesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            timesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            addTimePickerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            addTimePickerButton.widthAnchor.constraint(equalToConstant: 40),
            addTimePickerButton.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        addTimePickerButtonTopConstraint = addTimePickerButton.topAnchor.constraint(equalTo: timesTableView.bottomAnchor)
        addTimePickerButtonTopConstraint.isActive = true
        
        timesTableViewHeightConstraint = timesTableView.heightAnchor.constraint(equalToConstant: 0)
        timesTableViewHeightConstraint.isActive = true

    }
    
    private func loadData() {
        guard let model = model else { return }
        
        selectedOption = model.selectedOption
        if let selectedOption = selectedOption, let index = optionData.firstIndex(of: selectedOption) {
            for (index, subview) in buttonStackView.arrangedSubviews.enumerated() {
                if let buttonContainer = subview as? UIStackView,
                   let button = buttonContainer.arrangedSubviews.first as? UIButton {
                    button.setImage(optionImages[index], for: .normal) 
                }
            }
            
            if let buttonContainer = buttonStackView.arrangedSubviews[index] as? UIStackView,
               let button = buttonContainer.arrangedSubviews.first as? UIButton {
                button.setImage(optionImagesColor[index], for: .normal) // Set highlighted image
            }
        }
        
        selectedTimes = model.selectedTimes
        updateSelectedTimes()
        
        updateNextButtonStateStepTwo()
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

// MARK: - UITableViewDataSource, UITableViewDelegate
extension NewPillStepTwoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedTimes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: TimeCell.identifier, for: indexPath) as? TimeCell else {
            return UITableViewCell()
        }
        let time = selectedTimes[indexPath.row]
        cell.configure(with: "\(time.hour):\(time.minute)")
        cell.removeButton.tag = indexPath.row
        cell.removeButton.addTarget(self, action: #selector(didTapRemoveTimeCell(_:)), for: .touchUpInside)
        return cell
    }
    

}

// MARK: - TimePickerDelegate
extension NewPillStepTwoViewController: TimePickerDelegate {
    func didSelectTime(selectedTime: String) {
        print("Selected time: \(selectedTime)")

        let components = selectedTime.split(separator: ":")
        if components.count == 2 {
            let hour = String(components[0])
            let minute = String(components[1])
            selectedTimes.append((hour: hour, minute: minute))
            print("Current selected times: \(selectedTimes)")
            updateSelectedTimes()
            updateNextButtonStateStepTwo()
        }
    }
}
