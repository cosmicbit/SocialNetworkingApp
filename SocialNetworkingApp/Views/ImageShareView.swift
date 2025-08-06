//
//  ImageShareView.swift
//  SocialNetworkingApp
//
//  Created by Philips on 06/08/25.
//

import UIKit

class ImageShareView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: ) have not been implemented")
    }

    private func setupView(){
        backgroundColor = .green
    }
}
