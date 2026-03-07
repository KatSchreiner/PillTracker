//
//  ViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 06.04.2025.
//

import UIKit

final class MyPillsViewController: UIViewController {
    // MARK: - Properties
    var userName: String?
    private var viewModel = PillsViewModel()
    
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PillTableViewCell.self, forCellReuseIdentifier: PillTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        return tableView
    }()
    
    lazy var weeklyCalendarView: WeeklyCalendarView = {
        let view = WeeklyCalendarView()
        return view
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Привет, \(userName ?? "друг")!"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .dGray
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .dGray
        return label
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        return view
    }()
    
    lazy var addPillButton: UIButton = {
        let image = UIImage(systemName: "plus")!
        return CustomButton.smallButton(
            image: image,
            tintColor: .white,
            backgroundColor: .lBlue,
            cornerRadius: 8,  
            size: CGSize(width: 45, height: 45),
            target: self,
            action: #selector(didTapAddPillButton)
        )
    }()
    
    lazy var emptyStateView: UILabel = {
        let emptyStateLabel = UILabel()
        emptyStateLabel.text = "Здесь пока нет ни одной записи"
        emptyStateLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        emptyStateLabel.textColor = .dGray
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.isHidden = true
        return emptyStateLabel
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        viewModel.loadData(userName: userName)
        updateEmptyState()
    }
    
    init(userName: String?) {
        self.userName = userName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    @objc private func didTapAddPillButton() {
        addPillButton.animatePress()
        let addNewPill = AddNewPillViewController()
        addNewPill.delegate = self
        navigationController?.pushViewController(addNewPill, animated: true)
    }
    
    @objc func handleDaySwipe(_ gesture: UISwipeGestureRecognizer) {
        viewModel.handleDaySwipe(gesture, calendarView: weeklyCalendarView) { [weak self] newDate in
            self?.dateLabel.text = self?.viewModel.formattedDateString(for: newDate)
            
            let screenWidth = self?.view.bounds.width ?? 0
            let directionMultiplier: CGFloat = gesture.direction == .left ? 1 : -1
            self?.tableView.transform = CGAffineTransform(translationX: directionMultiplier * screenWidth, y: 0)
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
                self?.tableView.transform = .identity
            }, completion: nil)
        }
    }
    
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .background
        navigationItem.hidesBackButton = true
        weeklyCalendarView.delegate = self
        
        [userNameLabel, weeklyCalendarView, dateLabel, addPillButton, tableView, separatorView, emptyStateView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        weeklyCalendarView.currentDate = viewModel.selectedDate
        dateLabel.text = viewModel.formattedDateString(for: viewModel.selectedDate)
        addConstraint()
    }
    
    private func setupBindings() {
        viewModel.onPillsUpdated = { [weak self] in
            self?.tableView.reloadData()
            self?.updateEmptyState()
        }
        
        viewModel.onTakenPillsUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
        
        viewModel.onUserNameUpdated = { [weak self] name in
            self?.userNameLabel.text = name
        }
    }
    
    private func addConstraint() {
        NSLayoutConstraint.activate([
            userNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            weeklyCalendarView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 10),
            weeklyCalendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weeklyCalendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weeklyCalendarView.heightAnchor.constraint(equalToConstant: 70),
            weeklyCalendarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            separatorView.topAnchor.constraint(equalTo: weeklyCalendarView.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            emptyStateView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addPillButton.topAnchor, constant: -20),
            
            addPillButton.widthAnchor.constraint(equalToConstant: 50),
            addPillButton.heightAnchor.constraint(equalToConstant: 50),
            addPillButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addPillButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func updateEmptyState() {
        let count = viewModel.sortedPillsWithTimes().count
        emptyStateView.isHidden = count > 0
    }
}

// MARK: - UITableViewDataSource
extension MyPillsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sortedPillsWithTimes().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PillTableViewCell.identifier, for: indexPath) as! PillTableViewCell
        let pillsWithTimes = viewModel.sortedPillsWithTimes()
        let currentPillWithTime = pillsWithTimes[indexPath.row]
        
        configureCell(cell, with: currentPillWithTime.pill, time: currentPillWithTime.time)
        setupMarkAsTakenButton(cell, for: currentPillWithTime.pill, time: currentPillWithTime.time, indexPath: indexPath)
        return cell
    }
    
    private func configureCell(_ cell: PillTableViewCell, with pill: Pill, time: (hour: String, minute: String)) {
        cell.configure(with: pill, time: time)
        cell.howToTakeLabel.text = pill.howToTake == "Не важно" ? "Не зависит от приема пищи" : pill.howToTake
        
        let isTaken = viewModel.isPillTaken(pill: pill, time: time)
        let checkmarkImage = UIImage(systemName: "checkmark")
        
        cell.pillNameLabel.textColor = isTaken ? .gray : .dGray
        cell.pillTimeLabel.textColor = isTaken ? .gray : .dGray
        cell.markAsTakenButton.tintColor = isTaken ? .gray : .clear
        cell.markAsTakenButton.setImage(isTaken ? checkmarkImage : nil, for: .normal)
        cell.pillImageView.alpha = isTaken ? 0.5 : 1.0
        cell.pillImageView.tintColor = isTaken ? .gray : nil
    }
    
    private func setupMarkAsTakenButton(_ cell: PillTableViewCell, for pill: Pill, time: (hour: String, minute: String), indexPath: IndexPath) {
        cell.markAsTakenButtonAction = { [weak self] in
            guard let self = self else { return }
            
            viewModel.togglePillTakenStatus(pill: pill, time: time) { success in
                if success {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isLastRow = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        cell.separatorInset = isLastRow ? UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0) : .zero
    }
}

// MARK: – UITableViewDelegate
extension MyPillsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let pencilImage = UIImage(systemName: "pencil")?.withTintColor(.white, renderingMode: .alwaysOriginal),
              let trashImage = UIImage(systemName: "trash")?.withTintColor(.white, renderingMode: .alwaysOriginal) else { return nil }
        
        let editAction = UIContextualAction(style: .normal, title: nil) { [weak self] (action, view, completionHandler) in
            self?.handleEditAction(at: indexPath)
            completionHandler(true)
        }
        
        let deleteAction = UIContextualAction(style: .normal, title: nil) { [weak self] _, _, completionHandler in
            self?.handleDeleteAction(at: indexPath, in: tableView, completionHandler: completionHandler)
        }
        
        let diameter: CGFloat = 50
        let editImage = UIImage.circularImage(from: pencilImage, backgroundColor: .dBlue, diameter: diameter)
        let deleteImage = UIImage.circularImage(from: trashImage, backgroundColor: .lRed, diameter: diameter)
        
        editAction.image = editImage
        editAction.backgroundColor = .background
        
        deleteAction.image = deleteImage
        deleteAction.backgroundColor = .background
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    private func handleDeleteAction(at indexPath: IndexPath, in tableView: UITableView, completionHandler: @escaping (Bool) -> Void) {
        let pillsWithTimes = viewModel.sortedPillsWithTimes()
        guard indexPath.row < pillsWithTimes.count else {
            completionHandler(false)
            return
        }
        
        let pillWithTime = pillsWithTimes[indexPath.row]
        let pillToDelete = pillWithTime.pill
        let timeToDelete = pillWithTime.time
        
        let deleteAlertView = DeleteAlertViewController()
        deleteAlertView.titleText = "Удалить \(pillToDelete.name) в \(timeToDelete.hour):\(timeToDelete.minute)?"
        
        deleteAlertView.onDeleteSingleDose = { [weak self] in
            guard let self = self else {
                completionHandler(false)
                return
            }
            
            self.viewModel.removePillTime(
                pillId: pillToDelete.id,
                time: timeToDelete,
                date: self.viewModel.selectedDate
            ) { success in
                DispatchQueue.main.async {
                    if success {
                        self.tableView.reloadData()
                    }
                    completionHandler(success)
                }
            }
        }
        
        deleteAlertView.onDeleteFutureDoses = { [weak self] in
            guard let self = self else {
                completionHandler(false)
                return
            }
            
            self.viewModel.deletePill(pillToDelete.id) { success in
                DispatchQueue.main.async {
                    if success {
                        self.tableView.reloadData()
                    }
                    completionHandler(success)
                }
            }
        }
        
        deleteAlertView.onCancel = {
            completionHandler(false)
        }
        
        deleteAlertView.modalPresentationStyle = .custom
        deleteAlertView.transitioningDelegate = self
        present(deleteAlertView, animated: true, completion: nil)
    }
    
    private func handleEditAction(at indexPath: IndexPath) {
        let pillsWithTimes = viewModel.sortedPillsWithTimes()
        guard indexPath.row < pillsWithTimes.count else {
            print("Индекс за пределами массива")
            return
        }
        
        let pillToEdit = pillsWithTimes[indexPath.row].pill
        print("Редактируемое лекарство: \(pillToEdit.name)")
        
        let editMyPillView = EditMyPillViewController(addNewPillVC: AddNewPillViewController())
        editMyPillView.pill = pillToEdit
        editMyPillView.delegate = self
        navigationController?.pushViewController(editMyPillView, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

// MARK: - WeeklyCalendarViewDelegate
extension MyPillsViewController: WeeklyCalendarViewDelegate {
    func didSelectDate(_ date: Date) {
        viewModel.selectedDate = date
        dateLabel.text = viewModel.formattedDateString(for: date)
        tableView.reloadData()
        updateEmptyState()
    }
}

// MARK: - AddNewPillDelegate
extension MyPillsViewController: AddNewPillDelegate {
    func didAddPill(_ pill: Pill) {
        viewModel.addOrUpdatePill(pill)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension MyPillsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
