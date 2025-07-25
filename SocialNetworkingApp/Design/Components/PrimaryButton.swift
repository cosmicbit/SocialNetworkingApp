//
//  PrimaryButton.swift
//  SocialNetworkingApp
//
//

import Foundation
import UIKit


class PrimaryButton: UIButton {
    
    var cornerRadius: CGFloat = 6 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    var buttonColor: UIColor = UIColor.primary {
        didSet {
            backgroundColor = buttonColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
//    override func prepareForInterfaceBuilder() {
//        super.prepareForInterfaceBuilder()
//        setupView()
//    }
    
    func setupView() {
        backgroundColor = buttonColor
        titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        titleLabel?.textColor = UIColor.white
        layer.cornerRadius = cornerRadius
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = cornerRadius
    }
    
}
