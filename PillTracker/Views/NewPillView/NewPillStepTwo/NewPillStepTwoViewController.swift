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
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .dGray.withAlphaComponent(0.20)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.estimatedRowHeight = 60
        tableView.backgroundColor = .lGray
        tableView.layer.cornerRadius = 8
        tableView.clipsToBounds = true
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
    
    private var tableViewHeightConstraint: NSLayoutConstraint!
    private let maxTableViewHeight: CGFloat = UIScreen.main.bounds.height * 0.4
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isUserInteractionEnabled = true

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
    
    // MARK: - Public Methods
    func refreshTimesTableView() {
        viewModel.sortTimes()
        viewModel.pillStepTwoModel.selectedTimes = viewModel.selectedTimes
        updateTableViewHeight()
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
        tableViewHeightConstraint = timesTableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            timePickerLabel.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor, constant: 40),
            timePickerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            
            timesTableView.topAnchor.constraint(equalTo: timePickerLabel.bottomAnchor, constant: 20),
            timesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            timesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            timesTableView.heightAnchor.constraint(lessThanOrEqualToConstant: maxTableViewHeight),
            
            addTimePickerButton.topAnchor.constraint(equalTo: timesTableView.bottomAnchor, constant: 10),
            addTimePickerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            addTimePickerButton.widthAnchor.constraint(equalToConstant: 40),
            addTimePickerButton.heightAnchor.constraint(equalToConstant: 40),
        ])
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
    
    private func updateTableViewHeight() {
        let rowHeight: CGFloat = 60
        let numberOfRows = viewModel.selectedTimes.count
        var newHeight = CGFloat(numberOfRows) * rowHeight
        
        newHeight = min(newHeight, maxTableViewHeight)
        
        UIView.animate(withDuration: 0.3) {
            self.tableViewHeightConstraint.constant = newHeight
            self.view.layoutIfNeeded()
        }
        
        timesTableView.isScrollEnabled = true
        timesTableView.alwaysBounceVertical = true
        timesTableView.showsVerticalScrollIndicator = numberOfRows * Int(rowHeight) > Int(self.maxTableViewHeight)
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (action, view, completionHandler) in
            UIView.animate(withDuration: 0.2, animations: {
                if let cell = tableView.cellForRow(at: indexPath) {
                    cell.transform = CGAffineTransform(translationX: -cell.bounds.width, y: 0)
                    cell.alpha = 0
                }
            }) { _ in
                self?.viewModel.removeTime(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .none) 
                self?.updateTableViewHeight()
                self?.viewModel.checkValidity()
                completionHandler(true)
            }
        }
        
        let trashImage = UIImage(systemName: "trash")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        deleteAction.image = trashImage
        deleteAction.backgroundColor = .lRed
        
        let editAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completionHandler) in
            self?.editTime(at: indexPath)
            completionHandler(true)
        }
        
        let editImage = UIImage(systemName: "pencil")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        editAction.image = editImage
        editAction.backgroundColor = .dBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        
        return configuration
    }
    
    private func editTime(at indexPath: IndexPath) {
        let timeToEdit = viewModel.selectedTimes[indexPath.row]
        
        let timePickerView = TimePickerViewController()
        timePickerView.delegate = self
        timePickerView.editingIndex = indexPath.row
        
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.hour = Int(timeToEdit.hour)
        dateComponents.minute = Int(timeToEdit.minute)
        
        if let date = calendar.date(from: dateComponents) {
            timePickerView.timePicker.setDate(date, animated: false)
        }
        
        timePickerView.presentAsBottomSheet(on: self)
    }
}

// MARK: - TimePickerDelegate
extension NewPillStepTwoViewController: TimePickerDelegate {
    func didUpdateTime(selectedTime: String, at index: Int) {
        let components = selectedTime.split(separator: ":")
        if components.count == 2 {
            let hour = String(components[0])
            let minute = String(components[1])
            viewModel.updateTime(at: index, hour: hour, minute: minute)
            timesTableView.reloadData()
            viewModel.checkValidity()
        }
    }
    
    func didSelectTime(selectedTime: String) {
        let components = selectedTime.split(separator: ":")
        if components.count == 2 {
            let hour = String(components[0])
            let minute = String(components[1])
            viewModel.addTime(hour: hour, minute: minute)
            let newIndexPath = IndexPath(row: viewModel.selectedTimes.count - 1, section: 0)
            timesTableView.reloadData()
            updateTableViewHeight()
            viewModel.checkValidity()
        }
    }
}
