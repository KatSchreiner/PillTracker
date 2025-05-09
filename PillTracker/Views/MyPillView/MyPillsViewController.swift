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
    
    private var takenPills: [TakenPills] = []
    
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
        label.font = UIFont.systemFont(ofSize: 20)
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
        loadUser()
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
        
        dateLabel.text = formatDate(selectedDate)
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
        dateLabel.text = formatDate(selectedDate)
        
        addConstraint()
        addSwipeGestures()
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
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter.string(from: date)
    }
    
    private func addSwipeGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleDaySwipe(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleDaySwipe(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
    }
    
    private func loadPills() {
        pills = pillStore.fetchPills()
        tableView.reloadData()
    }
    
    private func loadUser() {
        guard let existingUser  = userStore.fetchUser () else {
            userNameLabel.text = "Привет, друг!"
            return
        }
        userNameLabel.text = "Привет, \(existingUser .name ?? "друг")!"
    }
}

// MARK: - WeeklyCalendarViewDelegate
extension MyPillsViewController: WeeklyCalendarViewDelegate {
    func didSelectDate(_ date: Date) {
        selectedDate = date
        dateLabel.text = formatDate(selectedDate)
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension MyPillsViewController: UITableViewDataSource {
    private func filteredPills() -> [Pill] {
        let weekDay = (Calendar.current.component(.weekday, from: selectedDate) + 5) % 7 + 1
        return pills.filter { $0.selectedDays.contains(weekDay) }
    }
    
    private func allTimes(for pills: [Pill]) -> [(hour: String, minute: String)] {
        return pills.flatMap { $0.times }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTimes(for: filteredPills()).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PillTableViewCell.identifier, for: indexPath) as! PillTableViewCell

        let pills = filteredPills()
        let times = allTimes(for: pills)
        let currentTime = times[indexPath.row]
        var currentPill: Pill?
        var timeIndex = 0

        for pill in pills {
            if timeIndex + pill.times.count > indexPath.row {
                currentPill = pill
                break
            }
            timeIndex += pill.times.count
        }

        if let pill = currentPill {
            cell.configure(with: pill, time: currentTime)

            let isTaken = takenPills.contains(where: { $0.pill.name == pill.name && $0.time.hour == currentTime.hour && $0.time.minute == currentTime.minute && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) })

            let checkmarkImage = UIImage(systemName: "checkmark")
            let tintColor: UIColor = isTaken ? UIColor.gray : .clear
            let backgroundColor: UIColor = isTaken ? UIColor.lGray : UIColor.white

            let textColor: UIColor = isTaken ? UIColor.gray : UIColor.black

            cell.contentView.backgroundColor = backgroundColor
            cell.pillNameLabel.textColor = textColor
            cell.pillTimeLabel.textColor = textColor
            cell.markAsTakenButton.tintColor = tintColor
            cell.markAsTakenButton.setImage(isTaken ? checkmarkImage : nil, for: .normal)

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.locale = Locale(identifier: "ru_RU")

            cell.markAsTakenButtonAction = { [weak self] in
                guard let self = self else { return }

                let isTaken = self.takenPills.contains(where: { $0.pill.name == pill.name && $0.time.hour == currentTime.hour && $0.time.minute == currentTime.minute && Calendar.current.isDate($0.date, inSameDayAs: self.selectedDate) })

                let newTintColor: UIColor = isTaken ? .clear : .gray
                let newBackgroundColor: UIColor = isTaken ? UIColor.white : UIColor.lGray

                UIView.animate(withDuration: 0.3, animations: {
                    cell.contentView.backgroundColor = newBackgroundColor
                    cell.markAsTakenButton.tintColor = newTintColor
                }) { _ in
                    UIView.transition(with: cell.markAsTakenButton, duration: 0.3, options: [.transitionCrossDissolve], animations: {
                        cell.markAsTakenButton.setImage(isTaken ? nil : checkmarkImage, for: .normal)
                    }, completion: nil)
                }

                if isTaken {
                    self.takenPills.removeAll(where: { $0.pill.name == pill.name && $0.time.hour == currentTime.hour && $0.time.minute == currentTime.minute && Calendar.current.isDate($0.date, inSameDayAs: self.selectedDate) })
                    print("❌ Отмена отметки: \(pill.name) в \(currentTime.hour):\(currentTime.minute) на \(dateFormatter.string(from: self.selectedDate))")
                } else {
                    let newTakenPill = TakenPills(pill: pill, time: currentTime, date: self.selectedDate)
                    self.takenPills.append(newTakenPill)
                    print("✅ Отметка как выпитое: \(pill.name) в \(currentTime.hour):\(currentTime.minute) на \(dateFormatter.string(from: self.selectedDate))")
                }

                tableView.reloadRows(at: [indexPath], with: .automatic)
                print("⚠️ Текущие отмеченные лекарства: \(self.takenPills.map { $0.pill.name }) на \(dateFormatter.string(from: self.selectedDate))")
            }
        }

        return cell
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
        let weekDay = (Calendar.current.component(.weekday, from: selectedDate) + 5) % 7 + 1
        let filteredPills = pills.filter { $0.selectedDays.contains(weekDay) }
        
        guard let (pillToRemove, timeIndex, timesCount) = findPillAndCount(for: filteredPills, at: indexPath.row) else {
            completionHandler(false)
            return
        }
        
        if let indexInPills = pills.firstIndex(where: { $0.name == pillToRemove.name }) {
            tableView.beginUpdates()
            if timesCount > 1 {
                pills[indexInPills].times.remove(at: indexPath.row - timeIndex)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } else {
                pills.remove(at: indexInPills)
                let indexPathsToDelete = (0..<timesCount).map { IndexPath(row: timeIndex + $0, section: 0) }
                tableView.deleteRows(at: indexPathsToDelete, with: .automatic)
            }
            tableView.endUpdates()
        }
        
        completionHandler(true)
    }
    
    private func handleEditAction(at indexPath: IndexPath) {
        let weekDay = (Calendar.current.component(.weekday, from: selectedDate) + 5) % 7 + 1
        let filteredPills = pills.filter { $0.selectedDays.contains(weekDay) }
        
        guard let (pillToEdit, _, _) = findPillAndCount(for: filteredPills, at: indexPath.row) else { return }
        
        let editMyPillView = EditMyPillViewController()
        navigationController?.pushViewController(editMyPillView, animated: true)
    }
    
    private func findPillAndCount(for filteredPills: [Pill], at index: Int) -> (pill: Pill, timeIndex: Int, timesCount: Int)? {
        var timeIndex = 0
        for pill in filteredPills {
            let count = pill.times.count
            if timeIndex + count > index {
                return (pill, timeIndex, count)
            }
            timeIndex += count
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}


// MARK: - AddNewPillDelegate
extension MyPillsViewController: AddNewPillDelegate {
    func didAddPill(_ pill: Pill) {
        pills.append(pill)
        pillStore.savePill(pill: pill)
        tableView.reloadData()
    }
}
