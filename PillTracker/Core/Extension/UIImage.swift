//
//  UIImage.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 17.02.2026.
//

import UIKit

extension UIImage {
    static func circularImage(from image: UIImage, backgroundColor: UIColor, diameter: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter))
            context.cgContext.setFillColor(backgroundColor.cgColor)
            context.cgContext.fillEllipse(in: rect)
            
            let iconSize = diameter * 0.5
            let iconRect = CGRect(x: (diameter - iconSize) / 2, y: (diameter - iconSize) / 2, width: iconSize, height: iconSize)
            image.draw(in: iconRect)
        }
    }
}
