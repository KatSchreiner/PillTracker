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
    
    var onRemoveButtonTapped: (() -> Void)?
    
    let removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "minus.circle"), for: .normal)
        button.tintColor = .red
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Private Properties
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .dGray
        label.textAlignment = .center
        label.backgroundColor = .lGray
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var containerStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [timeLabel, removeButton])
        stack.axis = .horizontal
        stack.spacing = 20
        stack.alignment = .center
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
        onRemoveButtonTapped = nil
    }
    
    @objc private func removeButtonTapped() {
        onRemoveButtonTapped?()
    }
    
    func configure(with timeText: String, onRemove: (() -> Void)? = nil) {
        timeLabel.text = timeText
        onRemoveButtonTapped = onRemove
    }
}
