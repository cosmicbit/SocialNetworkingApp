//
//  NewMessageTableHeaderView.swift
//  SocialNetworkingApp
//
//  Created by Philips on 28/07/25.
//

import UIKit

class NewMessageTableHeaderView: UIView {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var createGroupChatView: UIView!
    @IBOutlet weak var createGroupChatImageView: UIImageView!
    @IBOutlet weak var aiChatsView: UIView!
    @IBOutlet weak var aiChatsImageView: UIImageView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: nil)
        nib.instantiate(withOwner: self)
        contentView.frame = bounds
        addSubview(contentView)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        createGroupChatImageView.layer.cornerRadius = createGroupChatImageView.frame.width / 2
        aiChatsImageView.layer.cornerRadius = aiChatsImageView.frame.width / 2
    }
    
}
