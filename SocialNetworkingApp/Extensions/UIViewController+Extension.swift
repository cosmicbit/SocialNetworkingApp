//
//  Extension+UIViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 07/07/25.
//

import Foundation
import UIKit

extension UIViewController {
    func presentError(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    func presentError(title: String, message: String, completion: @escaping () -> Void){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion()
            alert.dismiss(animated: true)
            
        }
        alert.addAction(okAction)
        present(alert, animated: true )
    }
}

extension UIViewController {
    
    /// Presents a temporary, self-dismissing message at the bottom of the screen.
    /// - Parameters:
    ///   - message: The string message to display.
    ///   - duration: How long the message should be visible in seconds.
    func showToast(message: String, duration: TimeInterval = 2.0, bottomConstraintConstant: CGFloat = 50) {
        let toastContainer = UIView(frame: CGRect.zero)
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 15
        toastContainer.clipsToBounds = true
        
        let toastLabel = UILabel(frame: CGRect.zero)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14.0)
        toastLabel.text = message
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0 // Allows multiline text
        
        toastContainer.addSubview(toastLabel)
        self.view.addSubview(toastContainer)
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toastLabel.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 16),
            toastLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -16),
            toastLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: 8),
            toastLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -8),
            toastContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            toastContainer.widthAnchor.constraint(lessThanOrEqualTo: self.view.widthAnchor, multiplier: 0.8),
            toastContainer.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: bottomConstraintConstant)
        ])
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: { _ in
                toastContainer.removeFromSuperview()
            })
        })
    }
}
