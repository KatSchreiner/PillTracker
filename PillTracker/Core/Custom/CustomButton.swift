//
//  MakeButton.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 18.09.2025.
//

import UIKit

final class CustomButton {
    static func makeButton(
        title: String,
        titleColor: UIColor,
        backgroundColor: UIColor,
        cornerRadius: CGFloat = 10,
        contentEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20),
        font: UIFont = UIFont.systemFont(ofSize: 18),
        target: Any?,
        action: Selector
    ) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = cornerRadius
        button.addTarget(target, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
}
