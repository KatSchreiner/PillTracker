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
        label.backgroundColor = .lGray
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.lGray.cgColor
        label.layer.cornerRadius = Constants.defaultRadius
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
        
    lazy var bottomSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .background
        return view
    }()
    
    lazy var topSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .background
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        selectionStyle = .none
        backgroundColor = .background
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        [timeLabel, bottomSeparatorView, topSeparatorView].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        

        NSLayoutConstraint.activate([
            topSeparatorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topSeparatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topSeparatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topSeparatorView.heightAnchor.constraint(equalToConstant: 5),
            
            timeLabel.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            timeLabel.heightAnchor.constraint(equalToConstant: 44),
            
            bottomSeparatorView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor),
            bottomSeparatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomSeparatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomSeparatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomSeparatorView.heightAnchor.constraint(equalToConstant: 5)
        ])
    }
    
    func configure(with timeText: String) {
        timeLabel.text = timeText
    }
}
