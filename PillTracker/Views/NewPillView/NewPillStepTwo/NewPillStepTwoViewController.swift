//
//  NewPillStepTwoViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 07.04.2025.
//

import UIKit

final class NewPillStepTwoViewController: BaseStepViewController {
    // MARK: - Public Properties
    let viewModel = NewPillStepTwoViewModel()
    
    // MARK: - Private Properties
    private lazy var timePickerLabel = createLabel(text: "Время приема")
    
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
    
    lazy var addTimePickerButton: UIButton = {
        let image = UIImage(systemName: "plus")!
        return CustomButton.smallButton(
            image: image,
            tintColor: .dGray,
            backgroundColor: .lGray,
            cornerRadius: 8,
            size: CGSize(width: 45, height: 45),
            target: self,
            action: #selector(didTapAddTimePicker)
        )
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Constants.smallPadding
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        
        for (index, option) in viewModel.optionData.enumerated() {
            let buttonContainer = createOptionButtonContainer(option: option, index: index)
            stackView.addArrangedSubview(buttonContainer)
        }
        
        return stackView
    }()
    
    private var addTimePickerButtonTopConstraint: NSLayoutConstraint?
    private var timesTableViewHeightConstraint: NSLayoutConstraint?
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
        let selectedOption = viewModel.optionData[sender.tag]
        viewModel.setSelectedOption(selectedOption)
        viewModel.pillStepTwoModel.selectedIcon =  viewModel.optionImagesSelected[sender.tag]
        viewModel.pillStepTwoModel.selectedOption = viewModel.selectedOption
        
        updateOptionButtons(selectedIndex: sender.tag)
        viewModel.checkValidity()
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
        refreshTimesTableView()
        viewModel.checkValidity()
    }
    
    // MARK: - Public Methods
    func refreshTimesTableView() {
        viewModel.sortTimes()
        viewModel.pillStepTwoModel.selectedTimes = viewModel.selectedTimes
        
        let rowCount = viewModel.selectedTimes.count
        let timeCellHeight: CGFloat = 60
        let calculatedHeight = CGFloat(rowCount) * timeCellHeight
        
        timesTableViewHeightConstraint?.constant = min(calculatedHeight, maxTimesTableHeight)
        timesTableView.isScrollEnabled = calculatedHeight > maxTimesTableHeight
        
        addTimePickerButtonTopConstraint?.constant = rowCount > 0 ? 16 : 0
        
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
        addTimePickerButtonTopConstraint?.isActive = true
        
        timesTableViewHeightConstraint = timesTableView.heightAnchor.constraint(equalToConstant: 0)
        timesTableViewHeightConstraint?.isActive = true
        
    }
    
    private func setupBindings() {
        viewModel.onTimesUpdated = { [weak self] in
            self?.refreshTimesTableView()
        }
        
        viewModel.onValidationChange = { [weak self] isValid in
            self?.updateButtonState(isEnabled: isValid, isNextButton: true)
        }
    }
    
    private func loadData() {
        guard let selectedOption = viewModel.selectedOption,
              let selectedIndex = viewModel.optionData.firstIndex(of: selectedOption) else {
            viewModel.checkValidity()
            return
        }
        
        updateOptionButtons(selectedIndex: selectedIndex)
        viewModel.checkValidity()
    }
    
    private func updateOptionButtons(selectedIndex: Int) {
        for (index, subview) in buttonStackView.arrangedSubviews.enumerated() {
            guard let container = subview as? UIStackView,
                  let button = container.arrangedSubviews.first as? UIButton else { continue }
            
            let image = (index == selectedIndex) ? viewModel.optionImagesSelected[index] : viewModel.optionImagesDefault[index]
            
            UIView.transition(with: button, duration: 0.3, options: .transitionCrossDissolve, animations: {
                button.setImage(image, for: .normal)
                if index == selectedIndex {
                    button.animatePress()
                }
            })
        }
    }
    
    private func createOptionButtonContainer(option: String, index: Int) -> UIStackView {
        let button = UIButton(type: .custom)
        button.setTitle(option, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.setTitleColor(.dGray, for: .normal)
        button.tag = index
        button.addTarget(self, action: #selector(optionButtonTapped(_:)), for: .touchUpInside)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        
        button.adjustsImageWhenHighlighted = false
        
        if let image = viewModel.optionImagesDefault[index] {
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
        
        return buttonContainer
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension NewPillStepTwoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.selectedTimes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TimeCell.identifier, for: indexPath) as? TimeCell else {
            return UITableViewCell()
        }
        let time = viewModel.selectedTimes[indexPath.row]
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
            viewModel.addTime(hour: hour, minute: minute)
            refreshTimesTableView()
        }
    }
}
