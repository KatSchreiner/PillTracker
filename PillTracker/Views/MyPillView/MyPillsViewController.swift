//
//  ViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 06.04.2025.
//

import UIKit

class MyPillsViewController: UIViewController {
    
    var userName: String?
    
    // MARK: - Private Properties
    private var pills: [Pill] = []
    private let pillStore = PillStore()
    private let userStore = UserStore()
    private let takenPillsStore = TakenPillsStore()
    
    private var takenPills: [TakenPills] = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PillTableViewCell.self, forCellReuseIdentifier: PillTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.separatorColor = UIColor.lightGray.withAlphaComponent(0.5)
        return tableView
    }()
    
    lazy var weeklyCalendarView: WeeklyCalendarView = {
        let view = WeeklyCalendarView()
        return view
    }()
    
    lazy var bottomBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .lGray
        return view
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Привет, \(userName ?? "друг")!"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    lazy var dateLabelBackground: UIView = {
        let dateLabelBackground = UIView()
        dateLabelBackground.backgroundColor = .clear
        return dateLabelBackground
    }()
    
    lazy var addPillButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "plus")
        button.setImage(image, for: .normal)
        button.backgroundColor = .lBlue
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(didTapAddPillButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Private Properties
    private var selectedDate: Date = Date()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadPills()
        loadTakenPills()
        loadUser()
    }

    init(userName: String?) {
        self.userName = userName
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - IB Actions
    @objc
    private func didTapAddPillButton() {
        addPillButton.animatePress()
        
        let addNewPill = AddNewPillViewController()
        addNewPill.delegate = self
        navigationController?.pushViewController(addNewPill, animated: true)
    }
    
    @objc
    func handleDaySwipe(_ gesture: UISwipeGestureRecognizer) {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
        
        if gesture.direction == .left {
            if selectedDate >= weekEnd {
                weeklyCalendarView.currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: weeklyCalendarView.currentDate)!
            }
            selectedDate = calendar.date(byAdding: .day, value: 1, to: selectedDate)!
            
        } else if gesture.direction == .right {
            if selectedDate <= weekStart {
                weeklyCalendarView.currentDate = calendar.date(byAdding: .weekOfYear, value: -1, to: weeklyCalendarView.currentDate)!
            }
            selectedDate = calendar.date(byAdding: .day, value: -1, to: selectedDate)!
        }
        
        let screenWidht = view.bounds.width
        let directionMultiplier: CGFloat = gesture.direction == .left ? 1 : -1
        tableView.transform = CGAffineTransform(translationX: directionMultiplier * screenWidht, y: 0)
        tableView.reloadData()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            self.tableView.transform = .identity
        }, completion: nil)
        
        dateLabel.text = formattedDateString(for: selectedDate)
        weeklyCalendarView.updateSelectedDate(selectedDate)
        
        
    }
    
    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        weeklyCalendarView.delegate = self
        
        [userNameLabel, weeklyCalendarView, dateLabelBackground, dateLabel, addPillButton, bottomBorderView, tableView].forEach { view in
            self.view.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        selectedDate = Calendar.current.startOfDay(for: Date())
        weeklyCalendarView.currentDate = selectedDate
        dateLabel.text = formattedDateString(for: selectedDate)

        addConstraint()
    }
    
    private func addConstraint() {
        NSLayoutConstraint.activate([
            userNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            weeklyCalendarView.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 10),
            weeklyCalendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -10),
            weeklyCalendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10),
            weeklyCalendarView.heightAnchor.constraint(equalToConstant: 70),
            weeklyCalendarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            bottomBorderView.topAnchor.constraint(equalTo: weeklyCalendarView.bottomAnchor),
            bottomBorderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBorderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBorderView.heightAnchor.constraint(equalToConstant: 2),
            
            tableView.topAnchor.constraint(equalTo: weeklyCalendarView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addPillButton.topAnchor, constant: -20),
            
            addPillButton.widthAnchor.constraint(equalToConstant: 50),
            addPillButton.heightAnchor.constraint(equalToConstant: 50),
            addPillButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addPillButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func formattedDateString(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter.string(from: date)
    }

    
    private func loadPills() {
        pills = pillStore.fetchPills()

        tableView.reloadData()
    }
    
    private func loadTakenPills() {
        takenPills = takenPillsStore.fetchTakenPills() 
        tableView.reloadData()
    }
    
    private func loadUser () {
        if let userName = self.userName {
            userNameLabel.text = "Привет, \(userName)!"
        } else {
            userNameLabel.text = "Привет, друг!"
        }
    }
}

// MARK: - WeeklyCalendarViewDelegate
extension MyPillsViewController: WeeklyCalendarViewDelegate {
    func didSelectDate(_ date: Date) {
        selectedDate = date
        dateLabel.text = formattedDateString(for: selectedDate)
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension MyPillsViewController: UITableViewDataSource {
    private func filteredPills() -> [Pill] {
        let calendar = Calendar.current
        let currentDate = Calendar.current.startOfDay(for: selectedDate)

        return pills.filter { pill in
            if pill.selectedStartDate == nil || pill.selectedEndDate == nil {
                return false
            }
            let startDate = pill.selectedStartDate
            let endDate = pill.selectedEndDate
        
            guard currentDate >= startDate && currentDate <= endDate else {
                return false
            }

            if let interval = pill.selectedInterval {
                let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: currentDate).day ?? 0

                if interval == 0 {
                    let weekday = (calendar.component(.weekday, from: currentDate) + 5) % 7 + 1
                    if pill.selectedDays.contains(weekday) {
                        return true
                    } else {
                        return false
                    }
                    
                } else {
                    let isDisplayed = daysSinceStart % (interval + 1) == 0
                    return isDisplayed
                }
            }

            return false
        }
    }

    private func sortedPillsWithTimes() -> [(pill: Pill, time: (hour: String, minute: String))] {
        let filtered = filteredPills()
        var pillsWithTimes: [(pill: Pill, time: (hour: String, minute: String))] = []
        
        for pill in filtered {
            for time in pill.times {
                pillsWithTimes.append((pill: pill, time: time))
            }
        }
        
        pillsWithTimes.sort { (first, second) -> Bool in
            let firstTime = "\(first.time.hour):\(first.time.minute)"
            let secondTime = "\(second.time.hour):\(second.time.minute)"
            return firstTime < secondTime
        }
        
        return pillsWithTimes
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedPillsWithTimes().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PillTableViewCell.identifier, for: indexPath) as! PillTableViewCell
        
        let pillsWithTimes = sortedPillsWithTimes()
        let currentPillWithTime = pillsWithTimes[indexPath.row]
        let currentPill = currentPillWithTime.pill
        let currentTime = currentPillWithTime.time
        
        configureCell(cell, with: currentPill, time: currentTime)
        setupMarkAsTakenButton(cell, for: currentPill, time: currentTime, indexPath: indexPath)
        
        return cell
    }
    
    private func getPill(for rowIndex: Int, from pills: [Pill]) -> Pill? {
        var timeIndex = 0
        for pill in pills {
            if timeIndex + pill.times.count > rowIndex {
                return pill
            }
            timeIndex += pill.times.count
        }
        return nil
    }
    
    private func configureCell(_ cell: PillTableViewCell, with pill: Pill, time: (hour: String, minute: String)) {
        cell.configure(with: pill, time: time)
        
        if pill.howToTake == "Не важно" {
            cell.howToTakeLabel.text = "Не зависит от приема пищи"
        } else {
            cell.howToTakeLabel.text = pill.howToTake
        }
        
        let isTaken = takenPills.contains(where: { $0.pillId == pill.id && $0.time.hour == time.hour && $0.time.minute == time.minute && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) })
        
        let checkmarkImage = UIImage(systemName: "checkmark")
        let tintColor: UIColor = isTaken ? UIColor.gray : .clear
        let textColor: UIColor = isTaken ? UIColor.gray : UIColor.black
        
        cell.pillNameLabel.textColor = textColor
        cell.pillTimeLabel.textColor = textColor
        cell.markAsTakenButton.tintColor = tintColor
        cell.markAsTakenButton.setImage(isTaken ? checkmarkImage : nil, for: .normal)
        
        if isTaken {
                cell.pillImageView.alpha = 0.5
                cell.pillImageView.tintColor = UIColor.gray
            } else {
                cell.pillImageView.alpha = 1.0
                cell.pillImageView.tintColor = nil
            }
    }
    
    private func setupMarkAsTakenButton(_ cell: PillTableViewCell, for pill: Pill, time: (hour: String, minute: String), indexPath: IndexPath) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        cell.markAsTakenButtonAction = { [weak self] in
            guard let self = self else { return }
            
            let currentDate = Date()
            let isToday = Calendar.current.isDate(currentDate, inSameDayAs: self.selectedDate)
            
            if !isToday {
                print("❌ Нельзя отметить лекарство, так как это не текущая дата.")
                return
            }
            
            let currentHour = Calendar.current.component(.hour, from: currentDate)
            let currentMinute = Calendar.current.component(.minute, from: currentDate)
            let currentTime = (hour: String(currentHour), minute: String(currentMinute))
            
            let isTaken = self.takenPills.contains(where: { $0.pill.name == pill.name && $0.time.hour == time.hour && $0.time.minute == time.minute && Calendar.current.isDate($0.date, inSameDayAs: self.selectedDate) })
            
            let newTintColor: UIColor = isTaken ? .clear : .gray
            let newImage: UIImage? = isTaken ? nil : UIImage(systemName: "checkmark")
            
            if isTaken {
                self.takenPills.removeAll(where: { $0.pill.name == pill.name && $0.time.hour == time.hour && $0.time.minute == time.minute && Calendar.current.isDate($0.date, inSameDayAs: self.selectedDate) })
                self.takenPillsStore.removeTakenPill(pillId: pill.id, pill: pill, time: time, date: self.selectedDate)
                print("❌ Лекарство '\(pill.name)' не выпито \(dateFormatter.string(from: self.selectedDate)) в \(currentTime.hour):\(currentTime.minute)")
            } else {
                let newTakenPill = TakenPills(pillId: pill.id, pill: pill, time: time, date: self.selectedDate)
                self.takenPills.append(newTakenPill)
                self.takenPillsStore.addTakenPill(pill: pill, pillId: pill.id, time: time, date: self.selectedDate)
                print("✅ Лекарство '\(pill.name)' выпито \(dateFormatter.string(from: self.selectedDate)) в \(currentTime.hour):\(currentTime.minute)")
            }
            
            UIView.animate(withDuration: 0.3, animations: {
                cell.markAsTakenButton.tintColor = newTintColor
            }) { _ in
                UIView.transition(with: cell.markAsTakenButton, duration: 0.3, options: [.transitionCrossDissolve], animations: {
                    cell.markAsTakenButton.setImage(newImage, for: .normal)
                }, completion: nil)
            }
            
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            print("⚠️ Текущие отмеченные лекарства: \(self.takenPills.map { $0.pill.name }) на \(dateFormatter.string(from: self.selectedDate))")
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
        
        let deleteAction = createSwipeAction(title: nil, style: .destructive, image: UIImage(named: "deleteButton")) { [weak self] completionHandler in
            guard let self = self else {
                completionHandler(false)
                return
            }
            self.handleDeleteAction(at: indexPath, in: tableView, completionHandler: completionHandler)
        }
        
        let editAction = createSwipeAction(title: nil, style: .normal, image: UIImage(named: "editButton")) { [weak self] completionHandler in
            guard let self = self else {
                completionHandler(false)
                return
            }
            self.handleEditAction(at: indexPath)
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    private func createSwipeAction(title: String?, style: UIContextualAction.Style, image: UIImage?, handler: @escaping ( @escaping (Bool) -> Void) -> Void) -> UIContextualAction {
        let action = UIContextualAction(style: style, title: title) { (action, view, completionHandler) in
            handler(completionHandler)
        }
        action.image = image
        action.backgroundColor = (style == .destructive) ? .lRed : .dBlue
        return action
    }

    private func handleDeleteAction(at indexPath: IndexPath, in tableView: UITableView, completionHandler: @escaping (Bool) -> Void) {
        let sortedPills = sortedPillsWithTimes()
        
        guard indexPath.row < sortedPills.count else {
            print("Индекс за пределами массива sortedPills")
            completionHandler(false)
            return
        }

        let pillWithTime = sortedPills[indexPath.row]
        let pillToDelete = pillWithTime.pill
        let timeToDelete = pillWithTime.time
        
        guard let indexInPills = pills.firstIndex(where: { $0.id == pillToDelete.id }) else {
            print("Не удалось найти лекарство с ID: \(pillToDelete.id) в pills")
            completionHandler(false)
            return
        }

        let deleteAlertView = DeleteAlertViewController()
        deleteAlertView.titleText = "Удалить \(pillToDelete.name)"
        deleteAlertView.tableView = tableView

        deleteAlertView.onDeleteSingleDose = { [weak self] in
            guard let self = self else { return }
            self.tableView.beginUpdates()
            
            let indexesToDelete = sortedPills
                .enumerated()
                .filter { $0.element.pill.id == pillToDelete.id }
                .map { IndexPath(row: $0.offset, section: 0) }
            
            self.pills.removeAll(where: { $0.id == pillToDelete.id })
            self.tableView.deleteRows(at: indexesToDelete, with: .automatic)
            pillStore.deletePill(pillToDelete.id)
            
            self.pills = self.pillStore.fetchPills()
            self.tableView.reloadData()
            
            self.tableView.endUpdates()
            completionHandler(true)
        }

        deleteAlertView.onDeleteFutureDoses = { [weak self] in
            guard let self = self else { return }
            self.tableView.beginUpdates()
            
            let indexesToDelete = sortedPills
                .enumerated()
                .filter { $0.element.pill.id == pillToDelete.id }
                .map { IndexPath(row: $0.offset, section: 0) }
            
            self.pills.removeAll(where: { $0.id == pillToDelete.id })
            self.tableView.deleteRows(at: indexesToDelete, with: .automatic)
            pillStore.deletePill(pillToDelete.id)
            
            self.tableView.endUpdates()
            completionHandler(true)
        }

        deleteAlertView.onCancel = { [weak self] in
            guard let self = self else { return }
            self.tableView.setEditing(false, animated: true)
            completionHandler(false)
        }

        deleteAlertView.modalPresentationStyle = .custom
        deleteAlertView.transitioningDelegate = self

        present(deleteAlertView, animated: true, completion: nil)
    }

    private func handleEditAction(at indexPath: IndexPath) {
        let sortedPills = sortedPillsWithTimes()
        guard indexPath.row < sortedPills.count else {
            print("Индекс за пределами массива")
            return
        }
        
        let pillToEdit = sortedPills[indexPath.row].pill
        print("Редактируемое лекарство: \(pillToEdit.name)")
        
        let editMyPillView = EditMyPillViewController(addNewPillVC: AddNewPillViewController())
        editMyPillView.pill = pillToEdit
        editMyPillView.delegate = self
        navigationController?.pushViewController(editMyPillView, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - AddNewPillDelegate
extension MyPillsViewController: AddNewPillDelegate {
    func didAddPill(_ pill: Pill) {
        if let index = pills.firstIndex(where: { $0.id == pill.id }) {
            pills[index] = pill
            pillStore.updatePill(pill)
        } else {
            pills.append(pill)
            pillStore.savePill(pill: pill)
        }
        tableView.reloadData()
    }
}

extension MyPillsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
