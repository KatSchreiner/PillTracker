//
//  PillTableViewCell.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 08.04.2025.
//

import UIKit

class PillTableViewCell: UITableViewCell {
    static let identifier = "PillTableViewCell"
        
    let pillTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    let pillImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let pillNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let dosageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    let howToTakeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    let markAsTakenButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.gray.cgColor
        button.backgroundColor = .clear
        button.adjustsImageWhenHighlighted = false
        button.layer.masksToBounds = true
        return button
    }()
    
    var markAsTakenButtonAction: (() -> Void)?
    
    @objc private func didTapMarkAsTaken() {
        markAsTakenButtonAction?()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.white
        
        self.selectionStyle = .none
                
        [pillTimeLabel, pillImageView, pillNameLabel, dosageLabel, howToTakeLabel, markAsTakenButton].forEach { contentView in
            self.contentView.addSubview(contentView)
            contentView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        markAsTakenButton.addTarget(self, action: #selector(didTapMarkAsTaken), for: .touchUpInside)
        
        addConstraint()
    }
    
    private func addConstraint() {
        NSLayoutConstraint.activate([
            pillTimeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pillTimeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pillTimeLabel.widthAnchor.constraint(equalToConstant: 80),
            
            pillImageView.leadingAnchor.constraint(equalTo: pillTimeLabel.trailingAnchor, constant: 10),
            pillImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pillImageView.widthAnchor.constraint(equalToConstant: 50),
            pillImageView.heightAnchor.constraint(equalToConstant: 50),
            
            pillNameLabel.leadingAnchor.constraint(equalTo: pillImageView.trailingAnchor, constant: 10),
            pillNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            pillNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            dosageLabel.leadingAnchor.constraint(equalTo: pillNameLabel.leadingAnchor),
            dosageLabel.topAnchor.constraint(equalTo: pillNameLabel.bottomAnchor, constant: 5),
            
            howToTakeLabel.leadingAnchor.constraint(equalTo: pillNameLabel.leadingAnchor),
            howToTakeLabel.topAnchor.constraint(equalTo: dosageLabel.bottomAnchor, constant: 5),
            howToTakeLabel.trailingAnchor.constraint(equalTo: pillNameLabel.trailingAnchor),
            howToTakeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            markAsTakenButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            markAsTakenButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            markAsTakenButton.widthAnchor.constraint(equalToConstant: 25),
            markAsTakenButton.heightAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    func configure(with pill: Pill, time: (hour: String, minute: String)) {
        pillTimeLabel.text = "\(time.hour):\(time.minute)"
        pillImageView.image = pill.icon
        pillNameLabel.text = pill.name
        
        if pill.dosage.truncatingRemainder(dividingBy: 1) == 0 {
            dosageLabel.text = "\(Int(pill.dosage)) \(pill.unit)"
        } else {
            dosageLabel.text = "\(pill.dosage) \(pill.unit)"
        }
        
        howToTakeLabel.text = "\(pill.howToTake)"
    }
}
