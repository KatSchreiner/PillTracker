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
    
    static func smallButton(
        image: UIImage? = nil,
        tintColor: UIColor? = nil,
        backgroundColor: UIColor = .clear,
        cornerRadius: CGFloat = 8,
        size: CGSize = CGSize(width: 45, height: 45),
        target: Any?,
        action: Selector
    ) -> UIButton {
        let button = UIButton(type: .custom)
        
        if let image = image {
            button.setImage(image, for: .normal)
            button.tintColor = tintColor
        } else {
            button.tintColor = .clear
        }
        
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = cornerRadius
        button.clipsToBounds = true
        button.contentEdgeInsets = .zero
        button.addTarget(target, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        
        return button
    }
}
