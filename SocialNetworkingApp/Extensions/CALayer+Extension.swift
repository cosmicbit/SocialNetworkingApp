//
//  CALayer+Extension.swift
//  SocialNetworkingApp
//
//  Created by Philips on 13/08/25.
//

import UIKit

extension CALayer{
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
        self.addSublayer(overlay)
    }
}
