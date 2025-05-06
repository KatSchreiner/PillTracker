//
//  UIView.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 06.05.2025.
//

import UIKit

extension UIView {
    func applyShadow(color: UIColor = .black, opacity: Float = 0.1, offset: CGSize = CGSize(width: 0, height: 2), radius: CGFloat = 4) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
    }
}
