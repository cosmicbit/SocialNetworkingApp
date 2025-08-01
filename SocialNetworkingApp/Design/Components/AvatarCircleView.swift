//
//  AvatarCircleView.swift
//  SocialNetworkingApp
//
//  Created by Philips on 21/07/25.
//

import UIKit

class AvatarCircleView: UIView {
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill // Ensures the image fills the circle without distortion
        iv.clipsToBounds = true          // Crucial for clipping to the rounded corners
        iv.backgroundColor = .lightGray  // A good placeholder color
        iv.translatesAutoresizingMaskIntoConstraints = false // Essential for Auto Layout
        iv.tintColor = .darkGray
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        clipsToBounds = true
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])

    }
    override func layoutSubviews() {
        super.layoutSubviews()
        // Make the image view perfectly circular based on its final size
        imageView.layer.cornerRadius = imageView.bounds.width / 2
        // If AvatarCircleView itself should be circular:
        self.layer.cornerRadius = self.bounds.width / 2
        self.clipsToBounds = true // Crucial for self.layer.cornerRadius
    }

    // MARK: - Data Configuration (Optional)
    func configure(image: UIImage?) {
        imageView.image = image ?? UIImage(systemName: "person.fill") // Use system image as fallback
    }

    func configure(imageURL: URL?){
        if let imageURL = imageURL {
            imageView.sd_setImage(with: imageURL)
            
        }else{
            imageView.image = UIImage(systemName: "person.fill")
        }
    }
}
