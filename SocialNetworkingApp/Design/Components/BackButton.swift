//
//  BackButton.swift
//  SocialNetworkingApp
//
//  Created by Philips on 23/07/25.
//

import UIKit

class BackButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    func setupView(){
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold, scale: .large )
        let image = UIImage(systemName: "arrow.left", withConfiguration: config)
        
        setTitle("", for: .normal)
        setImage(image, for: .normal)
        backgroundColor = .white
        tintColor = .black
        
    }

}
