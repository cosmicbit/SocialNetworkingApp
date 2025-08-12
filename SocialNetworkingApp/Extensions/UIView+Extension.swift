//
//  Extension+UIView.swift
//  SocialNetworkingApp
//
//  Created by Philips on 15/07/25.
//

import Foundation
import UIKit

extension UIView {
    func getTranformToThisFrame(newFrame: CGRect) -> CGAffineTransform{
        let originalCenter = center
        let originalSize = bounds.size
        
        let scaleX = newFrame.width / originalSize.width
        let scaleY = newFrame.height / originalSize.height
        let scaleTransform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        
        let newCenter = CGPoint(x: newFrame.midX, y: newFrame.midY)
        let translationX = newCenter.x - originalCenter.x
        let translationY = newCenter.y - originalCenter.y
        let translationTransform = CGAffineTransform(translationX: translationX, y: translationY)
        
        let combinedTransform = scaleTransform.concatenating(translationTransform)
        
        return combinedTransform
    }
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        return renderer.image { rendererContext in
            self.layer.render(in: rendererContext.cgContext)
        }
    }
    func asImage(ofBounds newBounds: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: newBounds)
        return renderer.image { rendererContext in
            self.layer.render(in: rendererContext.cgContext)
        }
    }
}

extension UIView{
    func rotate(by degree: CGFloat){
        let radians = degree * .pi / 180
        self.transform = CGAffineTransform(rotationAngle: radians)
    }
}
