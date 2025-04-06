//
//  CalendarDayCell.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 06.04.2025.
//

import UIKit

class CalendarDayCell: UICollectionViewCell {
    lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        [dayLabel, dateLabel].forEach { contentView in
            self.contentView.addSubview(contentView)
            contentView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraint()
    }
    
    private func addConstraint() {
        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dayLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dayLabel.heightAnchor.constraint(equalToConstant: 20),
            
            dateLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dayLabel.text = dateFormatter.string(from: date)

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        dateLabel.text = dayFormatter.string(from: date)
    }
}
