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
    
    private func getQRCodeCIImage(data: Data?) -> CIImage?{
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("M", forKey: "inputCorrectionLevel")
        return qrFilter.outputImage
    }
    
    private func convertQRCodeSquaresToDots(ciImage: CIImage) -> CIImage? {
        guard let dotScreenFilter = CIFilter(name: "CIDotScreen") else { return nil }
        dotScreenFilter.setValue(ciImage, forKey: "inputImage")
        dotScreenFilter.setValue(2.0, forKey: "inputWidth") // Controls dot size
        dotScreenFilter.setValue(0.0, forKey: "inputAngle")
        dotScreenFilter.setValue(0.7, forKey: "inputSharpness")
        return dotScreenFilter.outputImage
    }
    
    private func setColor(ciImage: CIImage, with color: UIColor) -> CIImage? {
        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter?.setValue(ciImage, forKey: "inputImage")
        colorFilter?.setValue(CIColor(color: color), forKey: "inputColor0") // The foreground color
        colorFilter?.setValue(CIColor(color: UIColor.clear), forKey: "inputColor1") // The background color
        return colorFilter?.outputImage
    }
    
    private func scale(ciImage: CIImage) -> CIImage {
        let scaleX = 200 / ciImage.extent.size.width
        let scaleY = 200 / ciImage.extent.size.height
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        let scaledImage = ciImage.transformed(by: transform)
        return scaledImage
    }
    
    private func setGradient(ciImage: CIImage, colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) -> CIImage?{
        let gradientFilter = CIFilter(name: "CILinearGradient")
        guard let firstUIColor = colors.first, let lastUIColor = colors.last else { return nil }
        let firstColor = CIColor(color: firstUIColor)
        let lastColor = CIColor(color: lastUIColor)
        gradientFilter?.setValue(firstColor, forKey: "inputColor0")
        gradientFilter?.setValue(lastColor, forKey: "inputColor1")
        let extent = ciImage.extent
        let newStart = startPoint.rotatePoint(around: CGPoint(x: 0, y: 0), by: .pi/2)  // Need to rotate the point by 90 degrees cuz CGpoint cordinate space and
        let xPosStart = newStart.x * extent.width                                             // CIvector coordinate space has difference of 90 degrees
        let yPosStart = newStart.y * extent.height
        let newEnd = endPoint.rotatePoint(around: CGPoint(x: 0, y: 0), by: .pi/2)
        let xPosEnd = newEnd.x * extent.width
        let yPosEnd = newEnd.y * extent.height
        gradientFilter?.setValue(CIVector(x: xPosStart, y: yPosStart), forKey: "inputPoint1")
        gradientFilter?.setValue(CIVector(x: xPosEnd, y: yPosEnd), forKey: "inputPoint0")
        return gradientFilter?.outputImage?.cropped(to: extent)
    }
    
    private func makeTransparentBackground(ciImage: CIImage) -> CIImage?{
        let transparentBackgroundFilter = CIFilter(name: "CIMaskToAlpha")
        transparentBackgroundFilter?.setValue(ciImage, forKey: "inputImage")
        return transparentBackgroundFilter?.outputImage
    }
    
    private func maskImage(input: CIImage, inputBackground: CIImage) -> CIImage? {
        guard let sourceOverFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
        sourceOverFilter.setValue(inputBackground, forKey: "inputBackgroundImage")
        sourceOverFilter.setValue(input, forKey: "inputImage")
        return sourceOverFilter.outputImage
    }
    
    func generateQRCode(withColor color: UIColor = .black) -> UIImage? {
        let data = self.data(using: String.Encoding.ascii)
        guard let ciImage = getQRCodeCIImage(data: data),
              let coloredImage = setColor(ciImage: ciImage, with: color) else { return nil}
        let scaledImage = scale(ciImage: coloredImage)
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    func generateGradientQRCode(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) -> UIImage? {
        let data = self.data(using: String.Encoding.ascii)
        guard let ciImage = getQRCodeCIImage(data: data),
              let transparentQRCodeImage = makeTransparentBackground(ciImage: ciImage),
              let gradientImage = setGradient(ciImage: transparentQRCodeImage, colors: colors, startPoint: startPoint, endPoint: endPoint),
              let maskedImage = maskImage(input: transparentQRCodeImage, inputBackground: gradientImage)
            else { return nil}
        let scaledImage = scale(ciImage: maskedImage)
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}


