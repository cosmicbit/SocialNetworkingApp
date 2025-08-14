//
//  BorderView.swift
//  SocialNetworkingApp
//
//  Created by Philips on 05/08/25.
//

import Foundation
import UIKit

extension UIView {
    
    enum Side {
        case top, bottom, left, right
    }

    func applyBorders(for sides: Set<Side>, borderWidth: CGFloat, borderColor: UIColor = .black) {
        // Remove any existing border layers to prevent duplicates
        layer.sublayers?.filter { $0.name?.starts(with: "borderLayer_") ?? false }.forEach { $0.removeFromSuperlayer() }

        let boundsWidth = bounds.width
        let boundsHeight = bounds.height

        for side in sides {
            let borderLayer = CALayer()
            borderLayer.backgroundColor = borderColor.cgColor
            
            switch side {
            case .top:
                borderLayer.frame = CGRect(x: 0, y: 0, width: boundsWidth, height: borderWidth)
            case .bottom:
                borderLayer.frame = CGRect(x: 0, y: boundsHeight - borderWidth, width: boundsWidth, height: borderWidth)
            case .left:
                borderLayer.frame = CGRect(x: 0, y: 0, width: borderWidth, height: boundsHeight)
            case .right:
                borderLayer.frame = CGRect(x: boundsWidth - borderWidth, y: 0, width: borderWidth, height: boundsHeight)
            }
            
            // Set a name to easily identify and remove these layers later
            borderLayer.name = "borderLayer_\(side)"
            layer.addSublayer(borderLayer)
        }
    }
}
