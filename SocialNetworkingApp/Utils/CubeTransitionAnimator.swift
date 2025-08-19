//
//  CubeTransitionAnimator.swift
//  SocialNetworkingApp
//
//  Created by Philips on 19/08/25.
//


import UIKit

class CubeTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let isPresenting: Bool

    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 // Duration of the animation
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!
        let containerView = transitionContext.containerView

        // Add the 'to' view to the container first
        containerView.addSubview(toVC.view)

        // Set up a base transform with perspective
        var perspectiveTransform = CATransform3DIdentity
        perspectiveTransform.m34 = 1.0 / -500.0

        let initialToViewTransform: CATransform3D
        let finalFromViewTransform: CATransform3D

        // Define the transforms based on whether it's a presentation or dismissal
        if isPresenting {
            // For presentation (moving from right to center)
            initialToViewTransform = CATransform3DRotate(perspectiveTransform, .pi / 2, 0, 1, 0)
            finalFromViewTransform = CATransform3DRotate(perspectiveTransform, -(.pi / 2), 0, 1, 0)
            
            // Position the 'to' view for the start of the animation
            toVC.view.layer.transform = initialToViewTransform
        } else {
            // For dismissal (moving from center to left)
            initialToViewTransform = CATransform3DRotate(perspectiveTransform, -(.pi / 2), 0, 1, 0)
            finalFromViewTransform = CATransform3DRotate(perspectiveTransform, .pi / 2, 0, 1, 0)
        }

        // Animate the rotation of both views
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromVC.view.layer.transform = finalFromViewTransform
            toVC.view.layer.transform = perspectiveTransform
        }) { _ in
            // Reset the transform on the 'from' view to its original state
            fromVC.view.layer.transform = CATransform3DIdentity
            
            // Complete the transition
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
