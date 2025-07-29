//
//  MessageBarView.swift
//  SocialNetworkingApp
//
//  Created by Philips on 28/07/25.
//

import UIKit

class MessageBarView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var pictureButton: UIButton!
    @IBOutlet weak var stickerButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageBarStackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit(){
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: nil)
        nib.instantiate(withOwner: self)
        contentView.frame = bounds
        addSubview(contentView)
        setupView()
    }
    
    func setupView(){
        contentView.backgroundColor = .secondarySystemBackground
        searchButton.isHidden = true
        sendButton.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.frame.height / 2
        cameraButton.layer.cornerRadius = cameraButton.frame.width / 2
        searchButton.layer.cornerRadius = searchButton.frame.width / 2
        sendButton.layer.cornerRadius = sendButton.frame.height / 2
    }
}
