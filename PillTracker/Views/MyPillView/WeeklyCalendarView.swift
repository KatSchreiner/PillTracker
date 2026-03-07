//
//  WeeklyCalendarView.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 06.04.2025.
//

import UIKit

protocol WeeklyCalendarViewDelegate: AnyObject {
    func didSelectDate(_ date: Date)
}

final class WeeklyCalendarView: UIView {
    // MARK: - Public Properties
    weak var delegate: WeeklyCalendarViewDelegate?
    
    var currentDate: Date = Date() {
        didSet {
            populateDates()
        }
    }
    
    // MARK: - Private Properties
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .background
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(CalendarDayCell.self, forCellWithReuseIdentifier: "CalendarDayCell")
        return collectionView
    }()
    
    private var dates: [Date] = []
    private var selectedDate: Date?
    
    // MARK: - Override Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - IB Actions
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        let direction: Int = gesture.direction == .right ? -1 : 1
        guard let newDate = Calendar.current.date(byAdding: .weekOfYear, value: direction, to: currentDate) else { return }
        
        currentDate = newDate
        populateDates()
    }
    
    // MARK: - Private Methods
    private func setupView() {
        [collectionView].forEach { view in
            self.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraint()
        addSwipeGestures()
    }
    
    private func addConstraint() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func populateDates() {
        let newDates = Date.datesForWeek(from: currentDate)
        guard !dates.elementsEqual(newDates, by: { Calendar.current.isDate($0, inSameDayAs: $1)}) else { return }
        
        dates = newDates
        collectionView.reloadData()
    }
    
    private func addSwipeGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        collectionView.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        collectionView.addGestureRecognizer(swipeRight)
    }
}

// MARK: - UICollectionViewDataSource
extension WeeklyCalendarView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCell", for: indexPath) as! CalendarDayCell
        
        let date = dates[indexPath.item]
        cell.configure(with: date)
        
        let today = Calendar.current.startOfDay(for: Date())
        
        configureCellAppearance(cell, for: date, today: today)
        
        return cell
    }
    
    private func configureCellAppearance(_ cell: CalendarDayCell, for date: Date, today: Date) {
        let isToday = Calendar.current.isDate(date, inSameDayAs: today)
        let isSelected = selectedDate != nil && Calendar.current.isDate(date, inSameDayAs: selectedDate!)
        cell.updateAppearance(isToday: isToday, isSelected: isSelected)
    }
}

// MARK: – UICollectionViewDelegate
extension WeeklyCalendarView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedDate = dates[indexPath.item]
        //currentDate = selectedDate
        self.selectedDate = selectedDate
        
        delegate?.didSelectDate(selectedDate)
        
        collectionView.reloadData()
    }
}

// MARK: – UICollectionViewDelegateFlowLayout
extension WeeklyCalendarView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 7), height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
