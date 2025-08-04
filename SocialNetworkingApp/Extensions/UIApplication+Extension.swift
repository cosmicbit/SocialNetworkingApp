//
//  Extension.UIApplication.swift
//  SocialNetworkingApp
//
//  Created by Philips on 07/07/25.
//

import Foundation
import UIKit

extension UIApplication {
    static var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes.flatMap{( $0 as? UIWindowScene )?.windows ?? []}.first { $0.isKeyWindow }
    }
}
