//
//  RingView.swift
//  SocialNetworkingApp
//
//  Created by Philips on 21/07/25.
//

import UIKit

class RingView: UIView {
    // CAShapeLayer to draw the ring
    let ringLayer = CAShapeLayer()

    // Property to control the ring's visual state and trigger animation
    var hasNewStory: Bool = false { // Set initial to false, configure it later
        didSet {
            updateRingAppearance() // Update color based on state
            if hasNewStory {
                ringLayer.strokeColor = UIColor.red.cgColor // Default color
                
            } else {
                ringLayer.strokeColor = UIColor.gray.cgColor // Default color
                
            }
        }
    }
    
    var isAnimating:Bool = false {
        didSet{
            if isAnimating {
                startRingAnimation()
            } else {
                stopRingAnimation()
            }
        }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear // Make the UIView background transparent
        layer.addSublayer(ringLayer) // Add the shape layer once

        // Initial setup for the ringLayer
        ringLayer.lineWidth = 2.0
        ringLayer.fillColor = nil // No fill color for a ring
        
        ringLayer.lineCap = .round // Rounded ends for the stroke
        ringLayer.strokeStart = 0.0
        ringLayer.strokeEnd = 1.0 // Initially fully drawn
    }

    // MARK: - Layout

    // This is crucial for updating the ringLayer's path and frame when bounds change
    override func layoutSubviews() {
        super.layoutSubviews()
        // The ringLayer's frame should match the view's bounds
        ringLayer.frame = bounds

        // Calculate the path based on the current bounds
        let ringWidth: CGFloat = ringLayer.lineWidth // Use the layer's linewidth
        let insetRect = bounds.insetBy(dx: ringWidth / 2, dy: ringWidth / 2)
        let circlePath = UIBezierPath(ovalIn: insetRect).cgPath
        ringLayer.path = circlePath

    }

    // MARK: - Appearance Update

    private func updateRingAppearance() {
        ringLayer.strokeColor = hasNewStory ? UIColor.red.cgColor : UIColor.gray.cgColor
    }

    // MARK: - Animation Methods

    private func startRingAnimation() {
        // Stop any existing animation before starting a new one
        stopRingAnimation()


        // Example 3: If you want the strokeEnd to animate every time it becomes new
        // (This would run once, not repeat like pulse)
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = 0.0
        strokeEndAnimation.toValue = 1.0
        strokeEndAnimation.duration = 1.0
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        strokeEndAnimation.repeatCount = 1
        // Set fillMode and removedOnCompletion to keep the end state
        strokeEndAnimation.fillMode = .forwards
        strokeEndAnimation.isRemovedOnCompletion = false
        ringLayer.add(strokeEndAnimation, forKey: "strokeEndDraw")

        // If you want a continuous rotation:
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi * 2) // Rotate 360 degrees
        rotationAnimation.duration = 1.0 // Speed of rotation
        rotationAnimation.repeatCount = 1
        rotationAnimation.isRemovedOnCompletion = false // Keeps animation running when out of hierarchy briefly
        ringLayer.add(rotationAnimation, forKey: "continuousRotation")

    }

    private func stopRingAnimation() {
        // Remove animations from the specific ringLayer
        ringLayer.removeAllAnimations()
        ringLayer.opacity = 1.0 // Reset opacity
        ringLayer.transform = CATransform3DIdentity // Reset scale/rotation
        ringLayer.strokeEnd = 1.0 // Ensure it's fully drawn if strokeEnd was animated
    }
}
