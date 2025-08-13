//
//  ColorShareView.swift
//  SocialNetworkingApp
//
//  Created by Philips on 06/08/25.
//

import UIKit

class ColorShareView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    var currentGradient = GradientPreset.greenToBlue{
        didSet{
            gradientLayer.colors = currentGradient.cgColors
            gradientLayer.locations = currentGradient.locations
            gradientLayer.startPoint = currentGradient.startPoint
            gradientLayer.endPoint = currentGradient.endPoint
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeColorGradient(){
        currentGradient.toNextGradient()
    }
}
