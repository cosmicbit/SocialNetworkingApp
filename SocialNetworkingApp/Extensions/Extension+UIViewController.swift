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
