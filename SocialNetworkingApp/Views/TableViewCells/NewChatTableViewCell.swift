//
//  NewChatTableViewCell.swift
//  SocialNetworkingApp
//
//  Created by Philips on 28/07/25.
//

import UIKit

class NewChatTableViewCell: UITableViewCell {

    static let identifier = "NewChatTableViewCell"
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    private var userProfile: RemoteUserProfile!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(userProfile: RemoteUserProfile){
        self.userProfile = userProfile
        setupViews()
    }
    
    func setupViews(){
        avatarImageView.sd_setImage(with: userProfile.avatarImageURL)
        avatarImageView.contentMode = .scaleAspectFill
        nameLabel.text = userProfile.name
        usernameLabel.text = userProfile.username
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }
    
}
