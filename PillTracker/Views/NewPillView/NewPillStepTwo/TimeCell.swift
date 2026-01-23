//
//  TimeCell.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 27.05.2025.
//

import UIKit

final class TimeCell: UITableViewCell {
    // MARK: - Public Properties
    static let identifier = "TimeCell"
    
    // MARK: - Private Properties
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.defaultFontSize
        label.textColor = .dGray
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.layer.cornerRadius = Constants.defaultRadius
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    func configure(with timeText: String) {
        timeLabel.text = timeText
    }
}
