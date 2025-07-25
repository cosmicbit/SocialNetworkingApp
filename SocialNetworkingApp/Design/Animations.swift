//
//  Animations.swift
//  SocialNetworkingApp
//
//  Created by Philips on 14/07/25.
//
import UIKit
import Foundation

extension UIView{
    func scaleUpAnimation() {
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: [.curveEaseOut]) {
            self.transform = CGAffineTransform.identity
        }
    }
    
    func performCenterHeartAnimation() {
        // Reset state for the animated heart
        transform = CGAffineTransform(scaleX: 0.1, y: 0.1) // Start very small
        isHidden = false // Make it visible

        // Define target scale and end scale
        let largeScale: CGFloat = 1.2 // Slightly larger than final size for pop effect
        let finalScale: CGFloat = 1.0 // Final resting size

        // Use spring damping for a nice bounce effect
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: {
            self.transform = CGAffineTransform(scaleX: largeScale, y: largeScale) // Scale up to large
        }) { _ in
            // After the initial pop, scale down slightly to the final size
            UIView.animate(withDuration: 0.2, animations: {
                self.transform = CGAffineTransform(scaleX: finalScale, y: finalScale)
            }) { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1) // Reset for next time
                }){_ in
                    self.isHidden = true // Hide when completely faded
                }
            }
        }
    }
    
    func bottomUpAnimation() {
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut) {
            self.transform = .identity // Animates back to its original position
        }
    }
    
    func bounceEffect() {
        self.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.transform = .identity // Back to original size
            }
        }
    }
    
    func slideFromRightAnimation(){
        self.transform = CGAffineTransform(translationX: self.bounds.width, y: 0)
        UIView.animate(withDuration: 0.5, delay: 0) {
            self.transform = .identity
        }
    }
}
