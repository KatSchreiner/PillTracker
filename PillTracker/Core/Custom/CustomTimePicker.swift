//
//  CustomTimePicker.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 08.04.2025.
//

import UIKit

class CustomTimePicker: UIPickerView {
    var hours: [String] = []
    var minutes: [String] = []
                    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Methods
    func populateHours() {
        for hour in 0..<24 {
            hours.append(String(format: "%02d", hour))
        }
    }
    
    func populateMinutes() {
        for minute in stride(from: 0, to: 60, by: 5) {
            minutes.append(String(format: "%02d", minute))
        }
    }
    
    // MARK: Private Methods
    private func setupView() {
        self.delegate = self
        self.dataSource = self
        
        populateHours()
        populateMinutes()
    }
    
    private func createLabelTime(with text: String, font: UIFont = .systemFont(ofSize: 20), textColor: UIColor = .dGray) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        label.textAlignment = .center
        return label
    }
}

// MARK: UIPickerViewDataSource
extension CustomTimePicker: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return hours.count
        } else if component == 1 {
            return 1
        } else {
            return minutes.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if component == 0 {
            return createLabelTime(with: hours[row])
        } else if component == 1 {
            return createLabelTime(with: ":")
        } else {
            return createLabelTime(with: minutes[row])
        }
    }
}

// MARK: UIPickerViewDelegate
extension CustomTimePicker: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        60
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0: return 30
        case 1: return 20
        case 2: return 30
        default: return 0
        }
    }
}
