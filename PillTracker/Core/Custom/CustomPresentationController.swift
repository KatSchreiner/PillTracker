//
//  CustomPresentationController.swift
//  PillTracker
//
//  Created by Екатерина Шрайнер on 10.04.2025.
//

import UIKit

class CustomPresentationController: UIPresentationController {
    private var dimmingView: UIView!
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerBounds = containerView?.bounds else { return .zero }
        
        let size = presentedView?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize) ?? .zero
        
        let height = size.height
        
        return CGRect(x: 0, y: containerBounds.height - height, width: containerBounds.width, height: height)
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView.alpha = 0
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped))
               dimmingView.addGestureRecognizer(tapGesture)
        
        containerView.addSubview(dimmingView)
        
        UIView.animate(withDuration: 0.3) {
            self.dimmingView.alpha = 1
        }
        
        guard let presentedView = presentedView else { return }
        containerView.addSubview(presentedView)
        
        presentedView.frame = frameOfPresentedViewInContainerView
        presentedView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            presentedView.alpha = 1
        }
    }
    
    override func dismissalTransitionWillBegin() {
        guard let presentedView = presentedView else { return }
        UIView.animate(withDuration: 0.3) {
            presentedView.alpha = 0
        } completion: { _ in
            presentedView.removeFromSuperview()
        }
    }
    
    @objc
    private func dimmingViewTapped() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
