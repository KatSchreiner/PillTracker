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
    
    lazy var removeButton: UIButton = {
        let image = UIImage(named: "deleteTime")!
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Private Properties
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = Constants.defaultFontSize
        label.textColor = .dGray
        label.textAlignment = .center
        label.backgroundColor = .lGray
        label.layer.cornerRadius = Constants.defaultRadius
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var containerStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [timeLabel, removeButton])
        stack.axis = .horizontal
        stack.spacing = Constants.defaultPadding
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(containerStackView)
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            timeLabel.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timeLabel.text = nil
        removeButton.setImage(nil, for: .normal)
        removeButton.tag = -1
        removeButton.removeTarget(nil, action: nil, for: .allEvents)
    }
    
    func configure(with timeText: String, target: Any?, action: Selector, tag: Int) {
        timeLabel.text = timeText
        removeButton.tag = tag
        removeButton.removeTarget(nil, action: nil, for: .allEvents)
        removeButton.addTarget(target, action: action, for: .touchUpInside)
        
        if let image = UIImage(named: "deleteTime") {
            removeButton.setImage(image, for: .normal)
        }
    }
}
