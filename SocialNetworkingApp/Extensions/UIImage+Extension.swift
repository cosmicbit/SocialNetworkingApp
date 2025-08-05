//
//  UIImage+Extension.swift
//  SocialNetworkingApp
//
//  Created by Philips on 05/08/25.
//

import Foundation
import UIKit

extension UIImage {
    static func fromSVGPath(_ path: String, size: CGSize, color: UIColor) -> UIImage? {
        let bounds = CGRect(origin: .zero, size: size)
        
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let image = renderer.image { context in
            color.setFill()
            
            // Note: This is a simplified approach and may not work for all SVG path commands.
            // For a production app, a more robust SVG parser would be necessary.
            let pathElements = path.components(separatedBy: CharacterSet(charactersIn: "MLZl"))
            
            let bezierPath = UIBezierPath()
            
            for element in pathElements {
                let coordinates = element.components(separatedBy: " ")
                    .compactMap { Double($0) }
                
                if coordinates.count == 2 {
                    let x = CGFloat(coordinates[0])
                    let y = CGFloat(coordinates[1])
                    
                    if bezierPath.isEmpty {
                        bezierPath.move(to: CGPoint(x: x, y: y))
                    } else {
                        bezierPath.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            
            bezierPath.close()
            bezierPath.fill()
        }
        
        return image
    }
}
