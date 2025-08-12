//
//  String+Extension.swift
//  SocialNetworkingApp
//
//  Created by Philips on 12/08/25.
//

import UIKit
import CoreImage

extension String {
    func image() -> UIImage? {
        let size = CGSize(width: 50, height: 50) // Adjust size as needed
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        (self as NSString).draw(in: CGRect(origin: .zero, size: size),
                                withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 40)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension String {
    func generateQRCode(withColor color: UIColor = .black) -> UIImage? {
        // Use `self` to access the string content
        let data = self.data(using: String.Encoding.ascii)
        
        // 1. Generate the standard square-based QR code CIImage
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        
        guard let ciImage = qrFilter.outputImage else { return nil }
        
        // 2. Apply a CIDotScreen filter to convert squares into dots
        guard let dotScreenFilter = CIFilter(name: "CIDotScreen") else { return nil }
        dotScreenFilter.setValue(ciImage, forKey: "inputImage")
        dotScreenFilter.setValue(2.0, forKey: "inputWidth") // Controls dot size
        dotScreenFilter.setValue(0.0, forKey: "inputAngle")
        dotScreenFilter.setValue(0.7, forKey: "inputSharpness")
        
        guard let dotScreenImage = dotScreenFilter.outputImage else { return nil }
        
        // 3. Use CIFalseColor to set the final color of the dots
        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter?.setValue(dotScreenImage, forKey: "inputImage")
        colorFilter?.setValue(CIColor(color: color), forKey: "inputColor0") // The foreground color
        colorFilter?.setValue(CIColor(color: UIColor.clear), forKey: "inputColor1") // The background color
        
        guard let outputImage = colorFilter?.outputImage else { return nil }
        
        // 4. Scale and render the final image
        let scaleX = 200 / outputImage.extent.size.width
        let scaleY = 200 / outputImage.extent.size.height
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        let scaledImage = outputImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    func generateGradientQRCode(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) -> UIImage? {
        let data = self.data(using: String.Encoding.ascii)
        
        // 1. Generate the standard square-based QR code CIImage
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        guard let ciImage = qrFilter.outputImage else { return nil }
        
        // 2. Create a CIImage with a transparent background
        // This is the key step to isolate the QR code's pattern.
        let transparentBackgroundFilter = CIFilter(name: "CIMaskToAlpha")
        transparentBackgroundFilter?.setValue(ciImage, forKey: "inputImage")
        
        guard let transparentQRCodeImage = transparentBackgroundFilter?.outputImage else { return nil }
        
        // 3. Create the gradient CIImage
        let gradientFilter = CIFilter(name: "CILinearGradient")
        let ciColors = colors.map { CIColor(color: $0) }
        guard let firstColor = ciColors.first, let lastColor = ciColors.last else { return nil }
        
        gradientFilter?.setValue(firstColor, forKey: "inputColor0")
        gradientFilter?.setValue(lastColor, forKey: "inputColor1")
        gradientFilter?.setValue(CIVector(x: endPoint.x * ciImage.extent.width, y: endPoint.y * ciImage.extent.height), forKey: "inputPoint0")
        gradientFilter?.setValue(CIVector(x: startPoint.x * ciImage.extent.width, y: startPoint.y * ciImage.extent.height), forKey: "inputPoint1")
        
        guard let gradientImage = gradientFilter?.outputImage?.cropped(to: ciImage.extent) else { return nil }
        
        // 4. Layer the transparent QR code over the gradient using CISourceOverCompositing
        guard let sourceOverFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
        sourceOverFilter.setValue(gradientImage, forKey: "inputBackgroundImage")
        sourceOverFilter.setValue(transparentQRCodeImage, forKey: "inputImage") // The QR code now becomes the foreground
        
        guard let finalImage = sourceOverFilter.outputImage else { return nil }
        
        // 5. Scale and render the final image
        let outputSize = CGSize(width: 200, height: 200)
        let scaleX = outputSize.width / finalImage.extent.size.width
        let scaleY = outputSize.height / finalImage.extent.size.height
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        let scaledImage = finalImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}


