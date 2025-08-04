//
//  PushFromRightDelegate.swift
//  SocialNetworkingApp
//
//  Created by Philips on 23/07/25.
//

import UIKit

enum TransitionDirection {
    case fromRight, fromLeft, fromTop, fromBottom
}
// MARK: - PushTransitionDelegate
// A dedicated class to be the transitioning delegate
class PushTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {

    // Strong references to animators
    private let presentAnimator: PushPresentAnimator
    private let dismissAnimator: PushDismissAnimator
    
    var presentationDirection: TransitionDirection
    
    init(withDirection direction: TransitionDirection,presentDuration: TimeInterval = 0.5, dismissDuration: TimeInterval = 0.4) {
        
        self.presentationDirection = direction
        let dismissDirection = PushTransitionDelegate.reverse(direction: direction)
        self.presentAnimator = PushPresentAnimator(direction: direction, duration: presentDuration)
        self.dismissAnimator = PushDismissAnimator(direction: dismissDirection, duration: dismissDuration)
        
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

    // MARK: - Nested Present Animator
    private class PushPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
        private let duration: TimeInterval
        private let direction: TransitionDirection
        
        init(direction: TransitionDirection, duration: TimeInterval) {
            self.duration = duration
            self.direction = direction
        }

        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return duration
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let fromViewController = transitionContext.viewController(forKey: .from),
                  let toViewController = transitionContext.viewController(forKey: .to) else {
                return
            }
            
            let containerView = transitionContext.containerView
            let screenWidth = containerView.bounds.width
            let screenHeight = containerView.bounds.height
            
            containerView.addSubview(toViewController.view)
            let duration = transitionDuration(using: transitionContext)
             
            // Calculate initial transform based on direction
            switch direction {
            case .fromRight:
                toViewController.view.transform = CGAffineTransform(translationX: screenWidth, y: 0)
            case .fromLeft:
                toViewController.view.transform = CGAffineTransform(translationX: -screenWidth, y: 0)
            case .fromTop:
                toViewController.view.transform = CGAffineTransform(translationX: 0, y: -screenHeight)
            case .fromBottom:
                toViewController.view.transform = CGAffineTransform(translationX: 0, y: screenHeight)
            }
            
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                
                switch self.direction {
                case .fromRight:
                    fromViewController.view.transform = CGAffineTransform(translationX: -screenWidth, y: 0)
                case .fromLeft:
                    fromViewController.view.transform = CGAffineTransform(translationX: screenWidth, y: 0)
                case .fromTop:
                    fromViewController.view.transform = CGAffineTransform(translationX: 0, y: screenHeight)
                case .fromBottom:
                    fromViewController.view.transform = CGAffineTransform(translationX: 0, y: -screenHeight)
                }
                toViewController.view.transform = .identity//CGAffineTransform(translationX: 0, y: 0)
                
            }) { finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }

    // MARK: - Nested Dismiss Animator
    private class PushDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
        private let duration: TimeInterval
        private let direction: TransitionDirection
        
        init(direction: TransitionDirection, duration: TimeInterval) {
            self.duration = duration
            self.direction = direction
        }

        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return duration
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let fromViewController = transitionContext.viewController(forKey: .from),
                  let toViewController = transitionContext.viewController(forKey: .to) else {
                return
            }
            let containerView = transitionContext.containerView
            let screenWidth = containerView.bounds.width
            let screenHeight = containerView.bounds.height
            let duration = transitionDuration(using: transitionContext)
            
            // Calculate initial transform based on direction
            switch direction {
            case .fromRight:
                toViewController.view.transform = CGAffineTransform(translationX: screenWidth, y: 0)
            case .fromLeft:
                toViewController.view.transform = CGAffineTransform(translationX: -screenWidth, y: 0)
            case .fromTop:
                toViewController.view.transform = CGAffineTransform(translationX: 0, y: -screenHeight)
            case .fromBottom:
                toViewController.view.transform = CGAffineTransform(translationX: 0, y: screenHeight)
            }

            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                
                // 'from' view moves off screen in the dismiss direction
                switch self.direction {
                case .fromRight: // Dismissing to the right
                    fromViewController.view.transform = CGAffineTransform(translationX: -screenWidth, y: 0)
                case .fromLeft: // Dismissing to the left
                    fromViewController.view.transform = CGAffineTransform(translationX: screenWidth, y: 0)
                case .fromTop: // Dismissing to the top
                    fromViewController.view.transform = CGAffineTransform(translationX: 0, y: screenHeight)
                case .fromBottom: // Dismissing to the bottom
                    fromViewController.view.transform = CGAffineTransform(translationX: 0, y: -screenHeight)
                }
                toViewController.view.transform = .identity
                
            }) { finished in
                fromViewController.view.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
    
    private static func reverse(direction: TransitionDirection) -> TransitionDirection{
        switch direction {
        case .fromRight:
             .fromLeft
        case .fromLeft:
             .fromRight
        case .fromTop:
             .fromBottom
        case .fromBottom:
             .fromTop
        }
    }
}


