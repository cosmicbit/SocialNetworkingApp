//
//  ProfileDetailEntryButton.swift
//  SocialNetworkingApp
//
//  Created by Philips on 10/07/25.
//
import Foundation
import UIKit

class ProfileDetailEntryButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView() {
        contentHorizontalAlignment = .left
        setTitleColor(.lightGray, for: .disabled)
        let bottomBorder = CALayer()
        bottomBorder.backgroundColor = UIColor.gray.cgColor
        bottomBorder.frame = CGRect(x: 0, y: self.bounds.height - 0.5, width: self.bounds.width, height: 0.5)
        layer.addSublayer(bottomBorder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.backgroundColor = UIColor.white.cgColor
    }

}
