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

extension UIImage {
    /// Overlays another image on top of the current image.
    /// - Parameter overlayImage: The image to be placed on top.
    /// - Parameter rect: The frame to draw the overlay image within.
    /// - Returns: A new UIImage with the second image overlaid.
    func overlayWith(overlayImage: UIImage, in rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: self.size)
        let combinedImage = renderer.image { context in
            self.draw(at: .zero)
            overlayImage.draw(in: rect)
        }
        return combinedImage
    }
}

extension UIImage {
    func dominantColor() -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        
        // Use the system default color space.
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        let context = CGContext(data: &pixelData,
                                width: width,
                                height: height,
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
        
        guard let validContext = context else { return nil }
        validContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var colorCounts: [UInt32: Int] = [:]
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * bytesPerPixel
                let alpha = pixelData[pixelIndex + 3]
                
                // Ignore transparent pixels to avoid counting black from the background.
                if alpha == 0 {
                    continue
                }
                
                let red = pixelData[pixelIndex]
                let green = pixelData[pixelIndex + 1]
                let blue = pixelData[pixelIndex + 2]
                
                let colorKey = (UInt32(red) << 16) | (UInt32(green) << 8) | UInt32(blue)
                colorCounts[colorKey, default: 0] += 1
            }
        }
        
        guard let (dominantColorKey, _) = colorCounts.max(by: { $0.value < $1.value }) else {
            return nil
        }
        
        let red = CGFloat((dominantColorKey >> 16) & 0xFF) / 255.0
        let green = CGFloat((dominantColorKey >> 8) & 0xFF) / 255.0
        let blue = CGFloat(dominantColorKey & 0xFF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
