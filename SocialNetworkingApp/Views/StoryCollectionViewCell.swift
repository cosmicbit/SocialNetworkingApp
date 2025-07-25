//
//  StoryCollectionViewCell.swift
//  SocialNetworkingApp
//
//  Created by Philips on 22/07/25.
//

import UIKit

class StoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "StoryCollectionViewCell"
    
    private let userProfileManager = UserProfileManager()
    
    var userProfile: UserProfile!

    // Only the RingView instance
    let ringView: RingView = {
        let view = RingView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let avatarView: AvatarCircleView = {
        let view = AvatarCircleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Initialization

    // This initializer is called when the cell is instantiated from the Storyboard prototype cell
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews() // Call the method to add and constrain the ringView
        
    }

    // This initializer is called if the cell were registered programmatically (Path 1)
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews() // Call the method to add and constrain the ringView
    }
    
    // Inside StoryCollectionViewCell.swift
    override var isSelected: Bool {
        
        didSet {
            ringView.isAnimating = isSelected
        }
    }
    

    // This method handles adding the subview and setting up its Auto Layout constraints.
    private func setupViews() {
        
        
        // Always add custom subviews to the cell's contentView
        ringView.hasNewStory = true
        
        contentView.addSubview(avatarView)
        contentView.addSubview(ringView)
        
        
        NSLayoutConstraint.activate([
            avatarView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9), // Example: 50x50 points
            avatarView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.9)  // Ensure it's square for a perfect circle
        ])
        

        // Set up Auto Layout constraints for the RingView to fill the entire contentView
        // This ensures the RingView takes on the exact size of the cell determined by the UICollectionViewFlowLayout
        NSLayoutConstraint.activate([
            ringView.topAnchor.constraint(equalTo: contentView.topAnchor),
            ringView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ringView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            ringView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }

    // MARK: - Data Configuration

    // Add a configure method to pass any data needed to customize the ring (e.g., if it indicates an unread story)
    func configure(userId: String, hasNewStory: Bool) {
        ringView.hasNewStory = hasNewStory
        getUserProfile(userId: userId)
        
        
    }
    
    // MARK: - Private Methods
    
    private func getUserProfile(userId: String){
        userProfileManager.getUserProfileByUserID(userId: userId) { result in
            switch result {
            case .success(let userProfile):
                self.userProfile = userProfile
                self.avatarView.configure(imageURL: self.userProfile.avatarImageURL)
            case .failure(_):
                return
            }
        }
    }
    
    
    // MARK: - Reuse Preparation

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.configure(image: nil)
    }
}
