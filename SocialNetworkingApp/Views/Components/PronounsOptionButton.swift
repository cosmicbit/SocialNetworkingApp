//
//  PronounsOptionButton.swift
//  SocialNetworkingApp
//
//  Created by Philips on 18/08/25.
//

import UIKit

class PronounsOptionButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = 5
    }
    
    func setupView(){
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 9, weight: .medium)
        let image = UIImage(systemName: "xmark", withConfiguration: imageConfig)
        setImage(image, for: .normal)
        semanticContentAttribute = .forceRightToLeft
        backgroundColor = .white
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .black
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5)
        config.imagePadding = 5
        configuration = config
    }
    
    func setTitle(with title: String){
        guard var config = configuration else { return }
        var attributedContainer = AttributedString(title)
        attributedContainer.font = .systemFont(ofSize: 12, weight: .semibold)
        config.attributedTitle = attributedContainer
        configuration = config
    }
}
