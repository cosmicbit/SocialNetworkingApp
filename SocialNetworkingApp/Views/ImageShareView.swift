//
//  ImageShareView.swift
//  SocialNetworkingApp
//
//  Created by Philips on 06/08/25.
//

import UIKit

class ImageShareView: UIView {
    
    var isBlurred: Bool = true {
        didSet{
            blurredView.isHidden = !isBlurred
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: ) have not been implemented")
    }
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    let blurredView: UIView = {
        let blurEffect = UIBlurEffect(style: .regular) // Example: a subtle blur
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.translatesAutoresizingMaskIntoConstraints = false
        return blurredEffectView
    }()

    private func setupView(){
        imageView.image = UIImage()
        imageView.frame = bounds
        addSubview(imageView)
        blurredView.frame = bounds
        isBlurred = false
        addSubview(blurredView)
    }
    
    func changeBackgroundImage(with newImage: UIImage){
        imageView.image = newImage
    }
}
