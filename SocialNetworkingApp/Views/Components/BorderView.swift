//
//  BorderView.swift
//  SocialNetworkingApp
//
//  Created by Philips on 05/08/25.
//

import Foundation
import UIKit

extension UIView{
    
    func applyBorders(for sides: Set<side>, borderWidth: CGFloat, borderColor: UIColor = .black){
        let boundsWidth: CGFloat = bounds.width
        let boundsHeight: CGFloat = bounds.height
        for side in sides {
            let view = CALayer()
            view.backgroundColor = borderColor.cgColor
            switch side {
            case .top:
                view.frame = CGRect(x: 0, y: 0, width: boundsWidth, height: borderWidth)
            case .bottom:
                view.frame = CGRect(x: 0, y: boundsHeight, width: boundsWidth, height: borderWidth)
            case .left:
                view.frame = CGRect(x: 0, y: 0, width: borderWidth, height: boundsHeight)
            case .right:
                view.frame = CGRect(x: boundsWidth, y: 0, width: borderWidth, height: boundsHeight)
            }
            layer.addSublayer(view)
        }
    }
    
    enum side{
        case top, bottom, left, right
    }
}
