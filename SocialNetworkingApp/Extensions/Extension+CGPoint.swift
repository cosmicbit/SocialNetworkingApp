//
//  Extension+CGPoint.swift
//  SocialNetworkingApp
//
//  Created by Philips on 13/08/25.
//
import UIKit

extension CGPoint{
    func rotatePoint(around center: CGPoint, by angle: CGFloat) -> CGPoint {
        // 1. Translate the point to the origin
        let point = self
        let translatedPoint = CGPoint(x: point.x - center.x, y: point.y - center.y)

        // 2. Create the rotation transform
        let rotationTransform = CGAffineTransform(rotationAngle: angle)

        // 3. Apply the rotation to the translated point
        let rotatedPoint = translatedPoint.applying(rotationTransform)

        // 4. Translate the point back
        let finalPoint = CGPoint(x: rotatedPoint.x + center.x, y: rotatedPoint.y + center.y)

        return finalPoint
    }
}
