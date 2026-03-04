//
//  PillTableViewCell.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 08.04.2025.
//

import UIKit

final class PillTableViewCell: UITableViewCell {
    // MARK: - Public Properties
    static let identifier = "PillTableViewCell"
    
    lazy var pillTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textAlignment = .center
        label.textColor = .dGray
        return label
    }()
    
    lazy var pillImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var pillNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .dGray
        return label
    }()
    
    lazy var howToTakeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        return label
    }()
    
    lazy var markAsTakenButton = CustomButton.smallButton(
        image: nil,
        tintColor: .clear,
        backgroundColor: .clear,
        cornerRadius: 8,
        size: CGSize(width: 30, height: 30),
        target: self,
        action: #selector(didTapMarkAsTaken)
    )
    
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
    
    // MARK: - Callback
    var markAsTakenButtonAction: (() -> Void)?
    
    // MARK: - Private Properties
    private let dosageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    // MARK: - Overrides Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        pillTimeLabel.text = nil
        pillImageView.image = nil
        pillNameLabel.text = nil
        dosageLabel.text = nil
        howToTakeLabel.text = nil
        markAsTakenButton.setImage(nil, for: .normal)
        markAsTakenButton.tintColor = .clear
        markAsTakenButton.backgroundColor = .clear
        markAsTakenButton.layer.borderColor = UIColor.gray.cgColor
        markAsTakenButtonAction = nil
    }
    
    // MARK: - IB Actions
    @objc private func didTapMarkAsTaken() {
        markAsTakenButtonAction?()
    }
    
    // MARK: - Public Methods
    func configure(with pill: Pill, time: (hour: String, minute: String)) {
        pillTimeLabel.text = "\(time.hour):\(time.minute)"
        pillImageView.image = pill.icon
        pillNameLabel.text = pill.name
        dosageLabel.text = formattedDosage(pill.dosage, unit: pill.unit)
        howToTakeLabel.text = "\(pill.howToTake)"
    }
    
    // MARK: - Private Methods
    private func setupView() {
        self.backgroundColor = .lGray.withAlphaComponent(0.5)
        self.selectionStyle = .none
        
        [bottomSeparatorView, topSeparatorView, pillTimeLabel, pillImageView, pillNameLabel, dosageLabel, howToTakeLabel, markAsTakenButton].forEach { subview in
            self.contentView.addSubview(subview)
            subview.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupMarkAsTakenButton()
        addConstraint()
    }
    
    private func addConstraint() {
        NSLayoutConstraint.activate([
            bottomSeparatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomSeparatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomSeparatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomSeparatorView.heightAnchor.constraint(equalToConstant: 5),
            
            topSeparatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topSeparatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topSeparatorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topSeparatorView.heightAnchor.constraint(equalToConstant: 5),
            
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
            markAsTakenButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    private func formattedDosage(_ dosage: Double, unit: String) -> String {
        if dosage.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(dosage)) \(unit)"
        } else {
            return "\(dosage) \(unit)"
        }
    }
    
    private func setupMarkAsTakenButton() {
        markAsTakenButton.layer.borderWidth = 1.5
        markAsTakenButton.layer.borderColor = UIColor.gray.cgColor
        markAsTakenButton.layer.masksToBounds = true
        
        contentView.addSubview(markAsTakenButton)
        markAsTakenButton.translatesAutoresizingMaskIntoConstraints = false
    }
}
