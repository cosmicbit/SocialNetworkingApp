//
//  CreateAlertActionSheetButtton.swift
//  SocialNetworkingApp
//
//  Created by Philips on 14/07/25.
//

import UIKit

class CreateAlertActionSheetButtton: UIButton {

    func addBottomBorder() {
        
        let bottomBorder = CALayer()
        bottomBorder.backgroundColor = UIColor.lightGray.cgColor
        
        bottomBorder.frame = CGRect(x: 50, y: self.bounds.height - 0.25, width: self.bounds.width - 100, height: 0.25)
        layer.addSublayer(bottomBorder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tintColor = .black
        configuration?.imagePadding = 15
        contentMode = .scaleAspectFill
        addBottomBorder()
    }

}
