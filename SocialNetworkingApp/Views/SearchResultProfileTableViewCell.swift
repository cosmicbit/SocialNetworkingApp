//
//  SearchResultTableViewCell.swift
//  SocialNetworkingApp
//
//  Created by Philips on 17/07/25.
//

import UIKit
import SDWebImage

protocol SearchResultProfileTableViewCellDelegate: AnyObject{
    
}

class SearchResultProfileTableViewCell: UITableViewCell {
    
    static let identifier = "SearchResultProfileTableViewCell"
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    private weak var delegate: SearchResultProfileTableViewCellDelegate?
    private var userProfile: UserProfile!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.sd_setImage(with: userProfile.avatarImageURL)
        usernameLabel.text = userProfile.username
        nameLabel.text = userProfile.name
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(userProfile: UserProfile, delegate: SearchResultProfileTableViewCellDelegate){
        self.userProfile = userProfile
        self.delegate = delegate
    }
}
