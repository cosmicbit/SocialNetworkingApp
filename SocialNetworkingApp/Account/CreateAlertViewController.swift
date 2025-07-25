//
//  CreateAlertViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 14/07/25.
//

import UIKit

class CreateAlertViewController: UIViewController {
    lazy var actionSheetView : CreateAlertActionSheetView = {
        let actionSheetWidth = view.frame.width
        let actionSheetHeight: CGFloat = view.frame.height / 2 + 100
        let frame = CGRect(x: 0, y: view.frame.height - actionSheetHeight, width: actionSheetWidth, height: actionSheetHeight)
        let actionSheet = CreateAlertActionSheetView(frame: frame)
        return actionSheet
    }()
    
    lazy var tapView: UIView = {
        return UIView(frame: CGRect(x:0 , y: 0, width: view.frame.width, height: view.frame.height))
    }()
    
    init(){
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(closeActionSheetViewController))
        tapView.addGestureRecognizer(backgroundTap)
        view.addSubview(tapView)
        
        // Add a pan gesture recognizer to the view
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
        
        actionSheetView.transform = CGAffineTransform(translationX: 0, y: view.bounds.height)
        view.addSubview(actionSheetView)
    }
    
    @objc func closeActionSheetViewController() {
        dismiss(animated: true)
    }
    
    // MARK: - Pan Gesture Handler
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)

        switch gesture.state {
        case .began:
            // Store the initial position if needed, though translation handles resets
            break
        case .changed:
            // Only allow dragging downwards
            if translation.y >= 0 {
                actionSheetView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended:
            let dismissThreshold: CGFloat = 0 // Dismiss if dragged down by 1/3 of its height
            let velocityThreshold: CGFloat = 800 // Dismiss if velocity is high enough

            if translation.y > dismissThreshold || velocity.y > velocityThreshold {
                // Animate dismissal
                UIView.animate(withDuration: 0.3, animations: {
                    self.actionSheetView.frame.origin.y = self.view.frame.height // Move off-screen
                }) { _ in
                    self.dismiss(animated: false, completion: nil)
                }
            } else {
                // Animate back to original position
                UIView.animate(withDuration: 0.2) {
                    self.actionSheetView.transform = .identity // Reset position
                }
            }
        default:
            break
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        actionSheetView.bottomUpAnimation()
    }
}
