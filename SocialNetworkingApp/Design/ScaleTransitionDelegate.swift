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
    var parentPosition: CGPoint
    
    init(withDirection direction: ScaleDirection, position: CGPoint, presentDuration: TimeInterval = 0.3, dismissDuration: TimeInterval = 0.5) {
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
        private let position: CGPoint
        
        init(direction: ScaleDirection, duration: TimeInterval, position: CGPoint) {
            self.duration = duration
            self.direction = direction
            self.position = position
        }
        
        func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
            duration
        }
        
        func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
            guard let toViewController = transitionContext.viewController(forKey: .to) else {
                return
            }
            let containerView = transitionContext.containerView
            containerView.addSubview(toViewController.view)
            let duration = transitionDuration(using: transitionContext)
            switch direction {
            case .up:
                toViewController.view.transform = CGAffineTransform(scaleX: 0, y: 0)
            case .down:
                toViewController.view.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            //toViewController.view.transform = CGAffineTransform(translationX: position.x, y: position.y)
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                toViewController.view.transform = .identity
            }) { finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
    
    private class ScaleDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning{
        private let duration: TimeInterval
        private let direction: ScaleDirection
        private let position: CGPoint
        
        init(direction: ScaleDirection, duration: TimeInterval, position: CGPoint) {
            self.duration = 3
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
            switch direction {
            case .up:
                fromView.transform = CGAffineTransform(scaleX: 0, y: 0)
            case .down:
                fromView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            let targetPoint = position
            let scaledDownTopCenter = CGPoint(x: fromView.frame.midX - ((fromView.frame.width * 0.1) / 2), y: fromView.center.y - ((fromView.frame.height * 0.1) / 2))
            //let originalTopCenter = CGPoint(x: fromView.frame.midX, y: fromView.frame.minY)
            print(fromView.center, " - ", fromView.frame.midX, " - ", fromView.frame.minY)
            let offsetX = targetPoint.x - scaledDownTopCenter.x
            let offsetY = targetPoint.y - scaledDownTopCenter.y
            let scaleTransform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            let translateTransform = CGAffineTransform(translationX: offsetX, y: offsetY)
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                fromView.transform = scaleTransform.concatenating(translateTransform)
                
            }) { finished in
                //fromView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
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
