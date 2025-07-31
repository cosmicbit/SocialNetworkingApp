//
//  PostTableViewCell.swift
//  SocialNetworkingApp
//
//  Created by Philips on 18/07/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import SDWebImage
import AVFoundation

protocol PostTableViewCellDelegate: AnyObject {
    func postTableViewCell(_ cell: PostTableViewCell, didUpdateMediaHeightForPost postId: String)
}

class PostTableViewCell: UITableViewCell {
    
    static let identifier = "PostTableViewCell"

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var mediaDisplayView: UIView!
    @IBOutlet weak var imageContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var post: Post!
    private var postUserProfile: UserProfile?
    
    var postImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    var postVideoView: VideoContainerView = {
        let view = VideoContainerView()
        return view
    }()
    private var likeCountLocally: Int = 0
    private var isLikedLocally: Bool = false {
        didSet{
            updateLikeButton()
            likeCountLabel.text = "\(likeCountLocally)"
        }
    }
    var likeCountListener: ListenerRegistration?
    let postManager = PostManager()
    let likeManager = LikeManager()
    let userProfileManager = UserProfileManager()
    
    func configure(post: Post){
        self.post = post
        setupPost()
        hasUserLikedThePost()
        startListeningForLikeCount()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postVideoView.player?.pause() // Stop any current playback
        postVideoView.playerLayer?.removeFromSuperlayer() // Remove the layer from the view hierarchy
        postVideoView.player = nil // Release the AVPlayer instance
        postVideoView.playerLayer = nil // Release the AVPlayerLayer instance
        postVideoView.removePlayerObservers() // Crucial: Remove KVO and NotificationCenter observers
        postImageView.sd_cancelCurrentImageLoad() // Cancel image download for SDWebImage
        postImageView.image = nil // Clear the displayed image
        postImageView.isHidden = true
        postVideoView.isHidden = true
        avatarImageView.sd_cancelCurrentImageLoad()
        avatarImageView.image = nil
        usernameLabel.text = nil
        timeElapsedLabel.text = nil
        likeCountLabel.text = nil
        descriptionLabel.text = nil
        heartImageView.transform = CGAffineTransform(scaleX: 0, y: 0) // Reset animation state
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        addTapGesturesToPost()
        heartImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
        optionsButton.transform = CGAffineTransform(rotationAngle: .pi / 2)
        mediaDisplayView.insertSubview(postImageView, at: 0)
        mediaDisplayView.insertSubview(postVideoView, at: 0)
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        postVideoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            postImageView.topAnchor.constraint(equalTo: mediaDisplayView.topAnchor),
            postImageView.bottomAnchor.constraint(equalTo: mediaDisplayView.bottomAnchor),
            postImageView.leadingAnchor.constraint(equalTo: mediaDisplayView.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: mediaDisplayView.trailingAnchor),
            postVideoView.topAnchor.constraint(equalTo: mediaDisplayView.topAnchor),
            postVideoView.bottomAnchor.constraint(equalTo: mediaDisplayView.bottomAnchor),
            postVideoView.leadingAnchor.constraint(equalTo: mediaDisplayView.leadingAnchor),
            postVideoView.trailingAnchor.constraint(equalTo: mediaDisplayView.trailingAnchor)
        ])
        postImageView.isHidden = true
        postVideoView.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        postVideoView.playerLayer?.frame = postVideoView.bounds
    }
    
    deinit {
        postVideoView.player?.pause()
        postVideoView.player = nil
        postVideoView.playerLayer?.removeFromSuperlayer()
        postVideoView.playerLayer = nil
        postVideoView.removePlayerObservers()
    }
    
    @objc func postSingleTapped(_ sender: UITapGestureRecognizer){
        if sender.state == .ended {
            switch postVideoView.player?.timeControlStatus {
            case .paused:
                postVideoView.player?.play()
            case .waitingToPlayAtSpecifiedRate:
                postVideoView.player?.play()
            case .playing:
                postVideoView.player?.pause()
            case nil:
                postVideoView.player?.play()
            case .some(_):
                postVideoView.player?.play()
            }
        }
    }
    
    @objc func postDoubleTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended { // Ensure the gesture has completed
            heartImageView.performCenterHeartAnimation()
            updateLikeButton()
            if !isLikedLocally{
                isLikedLocally = true
                self.updateLikesCollection { _ in }
            }
        }
    }
    
    func addTapGesturesToPost(){
        mediaDisplayView?.isUserInteractionEnabled = true
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(postDoubleTapped(_: )))
        doubleTapGesture.numberOfTapsRequired = 2
        mediaDisplayView?.addGestureRecognizer(doubleTapGesture)
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(postSingleTapped(_: )))
        singleTapGesture.numberOfTapsRequired = 1
        mediaDisplayView.addGestureRecognizer(singleTapGesture)
    }
    
    func setupPost(){
        self.getPostUserProfile()
        self.avatarImageView.contentMode = .scaleAspectFill
        self.timeElapsedLabel.text = DateFormatter.localizedString(from: self.post.createdDate.dateValue(), dateStyle: .full, timeStyle: .none)
        self.displayMedia(type: post.type, mediaURL: post.contentURL)
        self.likeCountLabel.text = "\(self.likeCountLocally)"
        self.descriptionLabel.text = self.post.description
    }
    
    func displayMedia(type: Post.ContentType, mediaURL: URL?) {
        postVideoView.player?.pause()
        postVideoView.playerLayer?.removeFromSuperlayer()
        postVideoView.playerLayer = nil
        postVideoView.removePlayerObservers() // Remove observers from previous player/item
        postImageView.sd_cancelCurrentImageLoad() // Cancel any ongoing image downloads
        postVideoView.isHidden = true
        postImageView.isHidden = true
        if let existingConstraint = self.imageContainerHeightConstraint {
            existingConstraint.isActive = false
        }
        self.imageContainerHeightConstraint = self.mediaDisplayView.heightAnchor.constraint(equalTo: self.mediaDisplayView.widthAnchor, multiplier: 1 / self.post.size.ratio)
        self.imageContainerHeightConstraint.isActive = true
        self.setNeedsLayout()
        self.layoutIfNeeded() // Apply placeholder height
        guard let url = mediaURL else {
            print("Error: Media type selected but no URL provided. Displaying placeholder.")
            postImageView.isHidden = false
            postImageView.image = UIImage(systemName: "photo.fill.on.rectangle.fill")
            postImageView.contentMode = .scaleAspectFit
            return
        }
        switch type {
        case .video:
            postVideoView.isHidden = false
            postVideoView.setupVideoPlayer(with: url)
        case .image:
            DispatchQueue.main.async {
                self.postImageView.sd_setImage(with: url)
                self.postImageView.contentMode = .scaleAspectFill
                self.postImageView.translatesAutoresizingMaskIntoConstraints = false
            }
            postImageView.isHidden = false
        case .audio:
            print("🔊 Audio content handling is TBD. Displaying audio placeholder.")
            postImageView.isHidden = false
            postImageView.image = UIImage(systemName: "waveform")
            postImageView.contentMode = .scaleAspectFit
        }
    }
    
    func hasUserLikedThePost() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        guard let postId = post.id else {
            return
        }
        likeManager.getLikeOfUserOnPost(postId: postId, userId: userId) { result in
            switch result {
            case .success(let like):
                if self.isLikedLocally != like.isLiked{
                    self.isLikedLocally = like.isLiked
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func updateLikeButton() {
        let imageName: String = isLikedLocally ? "heart.fill" : "heart"
        likeButton.tintColor = isLikedLocally ? .systemRed : .black
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 23, weight: .regular, scale: .large)
        let image = UIImage(systemName: imageName, withConfiguration: largeConfig)
        likeButton.setImage(image, for: .normal)
        if isLikedLocally {
            self.likeButton.bounceEffect()
        }
    }
    
    func getPostUserProfile() {
        let userId = post.userId
        userProfileManager.getUserProfileByUserID(userId: userId) { result in
            switch result {
            case .success(let userProfile):
                self.setupPostUserProfile(with: userProfile)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func setupPostUserProfile(with profile: UserProfile){
        postUserProfile = profile
        if let imageURL = postUserProfile?.avatarImageURL {
            avatarImageView.sd_setImage(with: imageURL)
        }
        usernameLabel.text = postUserProfile?.username
    }
    
    func updateLikesCollection(completion: @escaping (_ result: Bool) -> Void ) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        guard let postId = post.id else {
            completion(false)
            return
        }
        likeManager.postLikeOfUserOnPost(userId: userId, postId: postId, likeOrNot: self.isLikedLocally)
    }
    
    func startListeningForLikeCount() {
        likeCountListener = postManager.listenForLikeCount(forPost: post) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let count):
                DispatchQueue.main.async {
                    self.likeCountLocally = count
                    self.likeCountLabel.text = "\(count)"
                }
            case .failure(let error):
                print("Error updating like count in UI: \(error.localizedDescription)")
            }
        }
    }
    
    @IBAction func optionsButtonTapped(_ sender: Any) {
        postVideoView.player?.play()
    }
    @IBAction func likeButtonTapped(_ sender: Any) {
        isLikedLocally.toggle()
        
        self.updateLikesCollection { result in
            if result {
                print("Success")
            }
            else{
                print("Failed")
            }
        }
    }
    @IBAction func commentButtonTapped(_ sender: Any) {
        postVideoView.player?.pause()
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
    }
    @IBAction func saveButtonTapped(_ sender: Any) {
    }
    
}

