//
//  ViewController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 06.04.2025.
//

import UIKit

class MyPillsViewController: UIViewController {
    // MARK: - Private Properties
    lazy var weeklyCalendarView: WeeklyCalendarView = {
        let view = WeeklyCalendarView()
        return view
    }()
    
    lazy var bottomBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = .lGray
        return view
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
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(didTapAddPillButton), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Private Properties
    private var selectedDate: Date = Date()
        
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - IB Actions
    @objc
    private func didTapAddPillButton() {
        let addNewPill = AddNewPillViewController()
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

        dateLabel.text = formatDate(selectedDate)
        weeklyCalendarView.updateSelectedDate(selectedDate)
    }

    // MARK: - Private Methods
    private func setupView() {
        view.backgroundColor = .systemBackground
                
        weeklyCalendarView.delegate = self
        
        [weeklyCalendarView, dateLabelBackground, dateLabel, addPillButton, bottomBorderView].forEach { view in
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
            dateLabelBackground.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            dateLabelBackground.heightAnchor.constraint(equalToConstant: 30),
            dateLabelBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dateLabelBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            dateLabel.bottomAnchor.constraint(equalTo: dateLabelBackground.bottomAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: dateLabelBackground.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: dateLabelBackground.trailingAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: dateLabelBackground.centerYAnchor),
            
            weeklyCalendarView.topAnchor.constraint(equalTo: dateLabelBackground.bottomAnchor),
            weeklyCalendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -10),
            weeklyCalendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10),
            weeklyCalendarView.heightAnchor.constraint(equalToConstant: 70),
            weeklyCalendarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            bottomBorderView.topAnchor.constraint(equalTo: weeklyCalendarView.bottomAnchor),
            bottomBorderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBorderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBorderView.heightAnchor.constraint(equalToConstant: 2),
            
            addPillButton.widthAnchor.constraint(equalToConstant: 70),
            addPillButton.heightAnchor.constraint(equalToConstant: 70),
            addPillButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
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
}

// MARK: - WeeklyCalendarViewDelegate
extension MyPillsViewController: WeeklyCalendarViewDelegate {
    func didSelectDate(_ date: Date) {
        selectedDate = date
        dateLabel.text = formatDate(selectedDate)
    }
}
