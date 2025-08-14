//
//  CALayer+Extension.swift
//  SocialNetworkingApp
//
//  Created by Philips on 13/08/25.
//

import UIKit

extension CALayer{
    func addCornerOverlay(withWidth thickness: CGFloat = 2,
                          withColor color: UIColor = .black,
                          withLength cornerLength: CGFloat = 30,
                          isRounded: Bool = false
    ){
        let width = self.bounds.width
        let height = self.bounds.height
        let overlay = CALayer()
        overlay.frame = self.bounds

        func addCorner(x: CGFloat, y: CGFloat, isLeft: Bool, isTop: Bool){
            let shapeLayer = CAShapeLayer()
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = color.cgColor
            shapeLayer.lineWidth = thickness
            shapeLayer.lineCap = .round
            let path = UIBezierPath()
            let xStart = x
            let yStart = isTop ? y + cornerLength : y - cornerLength
            let xEnd = isLeft ? x + cornerLength : x - cornerLength
            let yEnd = y
            let startPoint = CGPoint(x: xStart, y: yStart)
            let endPoint = CGPoint(x: xEnd, y: yEnd)
            let controlPoint = CGPoint(x: x, y: y)
            path.move(to: startPoint)
            path.addQuadCurve(to: endPoint, controlPoint: controlPoint)
            shapeLayer.path = path.cgPath
            overlay.addSublayer(shapeLayer)
        }
        
        addCorner(x: 0, y: 0, isLeft: true, isTop: true)
        addCorner(x: width, y: 0, isLeft: false, isTop: true)
        addCorner(x: 0, y: height, isLeft: true, isTop: false)
        addCorner(x: width, y: height, isLeft: false, isTop: false)
        self.addSublayer(overlay)
    }
}
