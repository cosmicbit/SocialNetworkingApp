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


extension UIView{
    func addCornerOverlay(withWidth thickness: CGFloat, withColor color: UIColor){
        let width = self.bounds.width
        let height = self.bounds.height
        let cornerLength: CGFloat = 30
        let overlay = CALayer()
        overlay.frame = self.bounds
        
        func addCorner(x: CGFloat, y: CGFloat, isLeftToRight: Bool, isTopToBottom: Bool){
            let hLine = CALayer()
            hLine.backgroundColor = color.cgColor
            let xPos = isLeftToRight ? x : x - cornerLength
            hLine.frame = CGRect(x: xPos, y: y, width: cornerLength, height: thickness)
            overlay.addSublayer(hLine)
            let vLine = CALayer()
            let yPos = isTopToBottom ? y : y - cornerLength
            vLine.backgroundColor = color.cgColor
            vLine.frame = CGRect(x: x, y: yPos, width: thickness, height: cornerLength)
            overlay.addSublayer(vLine)
        }
        
        addCorner(x: 0, y: 0, isLeftToRight: true, isTopToBottom: true)
        addCorner(x: width, y: 0, isLeftToRight: false, isTopToBottom: true)
        addCorner(x: 0, y: height, isLeftToRight: true, isTopToBottom: false)
        addCorner(x: width, y: height, isLeftToRight: false, isTopToBottom: false)
        layer.addSublayer(overlay)
    }
}
