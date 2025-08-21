//
//  CubeTransitionAnimator.swift
//  SocialNetworkingApp
//
//  Created by Philips on 19/08/25.
//


import UIKit

class CubeTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private let isPresenting: Bool
    private let duration: TimeInterval

    init(isPresenting: Bool, withDuration: TimeInterval) {
        self.isPresenting = isPresenting
        self.duration = withDuration
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration // Duration of the animation
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else { return }
        let containerView = transitionContext.containerView
        containerView.addSubview(toVC.view)
        var perspectiveTransform = CATransform3DIdentity
        perspectiveTransform.m34 = 1.0 / -500.0
        
        var initialTransformToVC: CATransform3D
        initialTransformToVC = perspectiveTransform
        initialTransformToVC = CATransform3DRotate(initialTransformToVC, .pi / 2, 0, 1, 0)
        toVC.view.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        toVC.view.layer.position = CGPoint(x: toVC.view.frame.width, y: toVC.view.frame.height / 2)
        toVC.view.layer.transform = initialTransformToVC
        
        var FinalTransformFromVC = perspectiveTransform
        FinalTransformFromVC = CATransform3DRotate(FinalTransformFromVC, -.pi / 2, 0, 1, 0)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toVC.view.layer.transform = CATransform3DIdentity
            toVC.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            toVC.view.layer.position = CGPoint(x: toVC.view.frame.width / 2, y: toVC.view.frame.height / 2)
            fromVC.view.layer.anchorPoint = CGPoint(x: 1, y: 0.5)
            fromVC.view.layer.position = CGPoint(x: 0, y: fromVC.view.frame.height / 2)
            fromVC.view.layer.transform = FinalTransformFromVC
        }) { _ in
            fromVC.view.layer.transform = CATransform3DIdentity
            fromVC.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            fromVC.view.layer.position = CGPoint(x: fromVC.view.frame.width / 2, y: fromVC.view.frame.height / 2)
            toVC.view.layer.transform = CATransform3DIdentity
            toVC.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            toVC.view.layer.position = CGPoint(x: toVC.view.frame.width / 2, y: toVC.view.frame.height / 2)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}


import UIKit

class InteractivePageTurnAnimator: UIPercentDrivenInteractiveTransition {

    var hasStarted = false
    weak var navigationController: UINavigationController?

    func beginTransition(to newVC: UIViewController) {
        print("begin transition")
        hasStarted = true
        if var viewControllers = navigationController?.viewControllers {
            viewControllers.removeLast()
            navigationController?.pushViewController(newVC, animated: true)
        }
    }
}
