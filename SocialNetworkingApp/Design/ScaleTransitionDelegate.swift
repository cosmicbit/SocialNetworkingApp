//
//  ScaleTransitionDelegate.swift
//  SocialNetworkingApp
//
//  Created by Philips on 01/08/25.
//

import Foundation
import UIKit

enum ScaleDirection{
    case up, down
}

class ScaleTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate{
    
    private let presentAnimator: ScalePresentAnimator
    private let dismissAnimator: ScaleDismissAnimator
    
    var presentationDirection: ScaleDirection
    var parentPosition: CGRect
    
    init(withDirection direction: ScaleDirection, position: CGRect, presentDuration: TimeInterval = 0.1, dismissDuration: TimeInterval = 0.3) {
        self.presentationDirection = direction
        self.parentPosition = position
        let dismissDirection = ScaleTransitionDelegate.reverse(direction: direction)
        self.presentAnimator = ScalePresentAnimator(direction: direction, duration: presentDuration, position: position)
        self.dismissAnimator = ScaleDismissAnimator(direction: dismissDirection, duration: dismissDuration, position: position)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissAnimator
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return nil // For a full-screen push, usually no custom presentation controller
    }

    private class ScalePresentAnimator: NSObject, UIViewControllerAnimatedTransitioning{
        
        private let duration: TimeInterval
        private let direction: ScaleDirection
        private let position: CGRect
        
        init(direction: ScaleDirection, duration: TimeInterval, position: CGRect) {
            self.duration = duration
            self.direction = direction
            self.position = position
        }
        
        func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
            duration
        }
        
        func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
            guard let toViewController = transitionContext.viewController(forKey: .to),
                  let toView = toViewController.view
            else {
                return
            }
            let containerView = transitionContext.containerView
            containerView.addSubview(toViewController.view)
            let duration = transitionDuration(using: transitionContext)
            let combinedTransform = toView.getTranformToThisFrame(newFrame: position)
            toView.transform = combinedTransform
            UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: {
                toView.transform = .identity
            }) { finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
    
    private class ScaleDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning{
        private let duration: TimeInterval
        private let direction: ScaleDirection
        private let position: CGRect
        
        init(direction: ScaleDirection, duration: TimeInterval, position: CGRect) {
            self.duration = duration
            self.direction = direction
            self.position = position
        }
        
        func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
            duration
        }
        
        func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
            guard let fromViewController = transitionContext.viewController(forKey: .from) else {
                return
            }
            guard let fromView = fromViewController.view else {
                return
            }
            let duration = transitionDuration(using: transitionContext)
            let combinedTransform = fromView.getTranformToThisFrame(newFrame: position)
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                fromView.transform = combinedTransform
            }) { finished in
                    fromViewController.view.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
    
    private static func reverse(direction: ScaleDirection) -> ScaleDirection{
        switch direction {
        case .up:
                .down
        case .down:
                .up
        }
    }
}
