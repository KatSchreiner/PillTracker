//
//  UIButton.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 16.04.2025.
//

import UIKit

extension UIButton {
    func applyShadow(color: UIColor = .lGray, opacity: Float = 0.5, offset: CGSize = CGSize(width: 0, height: 2), radius: CGFloat = 4) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false
    }
}
