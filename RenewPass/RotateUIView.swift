//
//  RotateUIView.swift
//  RenewPass
//
//  Created by Kino Roy on 2017-02-27.
//  Copyright © 2017 Kino Roy. All rights reserved.
//

/// Extends UIView to allow rotating the Renew/Request button in the RenewViewController
extension UIView {
    /// Rotates a UIView by 360 degrees
    func rotate360Degrees(duration: CFTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat.pi * 2.0
        rotateAnimation.duration = duration
        
        if let delegate: CAAnimationDelegate = completionDelegate as? CAAnimationDelegate {
            rotateAnimation.delegate = delegate
        }
        DispatchQueue.main.async {
            self.layer.add(rotateAnimation, forKey: nil)
        }
    }
}
