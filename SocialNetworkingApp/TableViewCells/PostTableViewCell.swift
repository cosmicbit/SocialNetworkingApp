//
//  ExplorePostTableViewCell.swift
//  SocialNetworkingApp
//
//  Created by Philips on 18/07/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import SDWebImage
import AVFoundation

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
    private var postImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    private var postVideoView: UIView = {
        let view = UIView()
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
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    func configure(post: Post){
        self.post = post
        setupPost()
        hasUserLikedThePost()
        startListeningForLikeCount()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        // --- Video Cleanup ---
        player?.pause() // Stop any current playback
        playerLayer?.removeFromSuperlayer() // Remove the layer from the view hierarchy
        player = nil // Release the AVPlayer instance
        playerLayer = nil // Release the AVPlayerLayer instance
        removePlayerObservers() // Crucial: Remove KVO and NotificationCenter observers

        // --- Image Cleanup ---
        postImageView.sd_cancelCurrentImageLoad() // Cancel image download for SDWebImage
        postImageView.image = nil // Clear the displayed image

        // --- Hide both views to ensure only the correct one appears on reuse ---
        postImageView.isHidden = true
        postVideoView.isHidden = true

        // --- Other UI Cleanup ---
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
        addDoubleTapGestureToPost()
        heartImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
        optionsButton.transform = CGAffineTransform(rotationAngle: .pi / 2)
        
        mediaDisplayView.insertSubview(postImageView, at: 0)
        mediaDisplayView.insertSubview(postVideoView, at: 0)
        
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        postVideoView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Constraints for postImageView
            postImageView.topAnchor.constraint(equalTo: mediaDisplayView.topAnchor),
            postImageView.bottomAnchor.constraint(equalTo: mediaDisplayView.bottomAnchor),
            postImageView.leadingAnchor.constraint(equalTo: mediaDisplayView.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: mediaDisplayView.trailingAnchor),

            // Constraints for postVideoView
            postVideoView.topAnchor.constraint(equalTo: mediaDisplayView.topAnchor),
            postVideoView.bottomAnchor.constraint(equalTo: mediaDisplayView.bottomAnchor),
            postVideoView.leadingAnchor.constraint(equalTo: mediaDisplayView.leadingAnchor),
            postVideoView.trailingAnchor.constraint(equalTo: mediaDisplayView.trailingAnchor)
        ])

        // Initial hidden state
        //postImageView.isHidden = true
        //postVideoView.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        playerLayer?.frame = postVideoView.bounds

    }
    
    deinit {
        // Stop playback and clean up observers when the view controller is deallocated
        player?.pause()
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        // If you added observers, make sure to invalidate them
        removePlayerObservers()
    }
    
    
    @objc func postDoubleTapped(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended { // Ensure the gesture has completed
            heartImageView.performCenterHeartAnimation()
            updateLikeButton()
            if !isLikedLocally{
                isLikedLocally = true
                self.updateLikesCollection { result in
                    if result {
                        print("Success")
                    }
                    else{
                        print("Failed")
                    }
                }
            }
        }
    }
    
    func addDoubleTapGestureToPost(){
        mediaDisplayView?.isUserInteractionEnabled = true
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(postDoubleTapped(_: )))
        doubleTapGesture.numberOfTapsRequired = 2
        mediaDisplayView?.addGestureRecognizer(doubleTapGesture)
    }
    
    func setupPost(){
        self.getPostUserProfile()
        self.avatarImageView.contentMode = .scaleAspectFill
        self.timeElapsedLabel.text = DateFormatter.localizedString(from: self.post.createdDate, dateStyle: .full, timeStyle: .none)
        displayMedia(type: post.type, mediaURL: post.contentURL)
        self.likeCountLabel.text = "\(self.likeCountLocally)"
        self.descriptionLabel.text = self.post.description
    }
    
    func displayMedia(type: Post.ContentType, mediaURL: URL?) {
        // --- Pre-display cleanup for safety and visual correctness ---
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        removePlayerObservers() // Remove observers from previous player/item
        postImageView.sd_cancelCurrentImageLoad() // Cancel any ongoing image downloads

        // --- Hide both media views initially ---
        postVideoView.isHidden = true
        postImageView.isHidden = true

        guard let url = mediaURL else {
            print("Error: Media type selected but no URL provided. Displaying placeholder.")
            postImageView.isHidden = false
            postImageView.image = UIImage(systemName: "photo.fill.on.rectangle.fill")
            postImageView.contentMode = .scaleAspectFit
            imageContainerHeightConstraint.constant = 200.0 // Default height for placeholder
            self.layoutIfNeeded() // Apply placeholder height
            return
        }

        switch type {
        case .video:
            postVideoView.isHidden = false
            setupVideoPlayer(with: url)

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
            postVideoView.isHidden = true
            postImageView.image = UIImage(systemName: "waveform")
            postImageView.contentMode = .scaleAspectFit
            imageContainerHeightConstraint.constant = 100.0 // A reasonable height for an audio UI element
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Video Player Setup
    func setupVideoPlayer(with videoURL: URL) {
        guard let path = Bundle.main.path(forResource: "sample_video", ofType: "mp4") else {
            print("❌ Error: Video file 'sample_video.mp4' not found in bundle.")
            return
        }
        let videoContainerView = postVideoView
        let videoURL = URL(fileURLWithPath: path)
        let playerItem = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: playerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        if let playerLayer = playerLayer {
            videoContainerView.layer.addSublayer(playerLayer)
        }
        playerLayer?.frame = videoContainerView.bounds
        addPlayerObservers()
       // player?.play()
    }
    
    // MARK: - Player Observers (Recommended for Robustness)

    var playerItemStatusObservation: NSKeyValueObservation?
    var playerDidEndObservation: NSObjectProtocol? // For NotificationCenter

    func addPlayerObservers() {
        guard let player = player else { return }

        // Observe AVPlayerItem's status to know when it's ready to play or if an error occurred.
        playerItemStatusObservation = player.currentItem?.observe(\.status, options: [.new, .old], changeHandler: { (playerItem, change) in
            switch playerItem.status {
            case .readyToPlay:
                print("✅ PlayerItem is ready to play.")
                // You can safely start playing here, or update UI (e.g., enable play button)
            case .failed:
                print("❌ PlayerItem failed to load: \(playerItem.error?.localizedDescription ?? "Unknown error")")
                // Handle error (e.g., show an alert to the user)
            case .unknown:
                print("❔ PlayerItem status is unknown.")
                break
            @unknown default:
                fatalError("Unknown AVPlayerItem status")
            }
        })

        // Observe when the video finishes playing
        playerDidEndObservation = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { [weak self] _ in
            print("🔄 Video finished playing. Looping...")
            // Loop the video: seek back to the beginning
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }
    }

    func removePlayerObservers() {
        playerItemStatusObservation?.invalidate()
        playerItemStatusObservation = nil

        if let observation = playerDidEndObservation {
            NotificationCenter.default.removeObserver(observation)
            playerDidEndObservation = nil
        }
    }
    
    func hasUserLikedThePost() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        let postId = post.id
        Firestore.firestore().collection("likes").whereField("userId", isEqualTo: userId)
            .whereField("postId",isEqualTo: postId)
            .getDocuments(){ [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error checking for existing reaction: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("QuerySnapshot documents were nil unexpectedly.")
                    return
                }
                
                if let existingDocument = documents.first {
                    if let likeData = Like(snapshot: existingDocument){
                        if isLikedLocally != likeData.isLiked{
                            isLikedLocally = likeData.isLiked
                        }
                    }
                }
                
            }
    }
    
    func updateLikeButton() {
        let imageName: String
        
        if isLikedLocally {
            imageName = "heart.fill"
            likeButton.tintColor = .systemRed
        }
        else {
            imageName = "heart"
            likeButton.tintColor = .black
        }
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 23, weight: .regular, scale: .large)
        let image = UIImage(systemName: imageName, withConfiguration: largeConfig)
        likeButton.setImage(image, for: .normal)
        
        // Bounce-Effect for like button
        if isLikedLocally {
            self.likeButton.bounceEffect()
        }
    }
    
    func getPostUserProfile() {
        let userId = post.userId
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(userId)
        docRef.getDocument { [weak self] document, error in
            guard let strongSelf = self else {
                return
            }
            if let _ = error {
//                strongSelf.presentError(title: "Profile Error", message: "Cannot retrieve profile at the moment. Please try again later.")
                return
            }
            guard let document = document, document.exists  else{
                //strongSelf.presentError(title: "Profile Error", message: "Cannot retrieve profile at the moment. Please try again later.")
                print("Document does not exist or error fetching document: \(error?.localizedDescription ?? "No error description")")
                return
            }
            guard let userProfile = UserProfile(snapshot: document) else {
                //strongSelf.presentError(title: "Profile Error", message: "Cannot retrieve profile at the moment. Please try again later.")
                return
            }
            if let imageURL = userProfile.avatarImageURL {
                strongSelf.avatarImageView.sd_setImage(with: imageURL)
            }
            
            strongSelf.usernameLabel.text = userProfile.username
            
        }
    }
    
    func updateLikesCollection(completion: @escaping (_ result: Bool) -> Void ) {
        
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        let postId = post.id
        Firestore.firestore().collection("likes").whereField("userId", isEqualTo: userId)
            .whereField("postId",isEqualTo: postId)
            .getDocuments(){ [weak self] querySnapshot, error in
                
            guard let self = self else {
                completion(false)
                return
            }

            if let error = error {
                print("Error checking for existing reaction: \(error.localizedDescription)")
                completion(false)
                return
            }

            guard let documents = querySnapshot?.documents else {
                print("QuerySnapshot documents were nil unexpectedly.")
                completion(false)
                return
            }

            if let existingDocument = documents.first {
                let documentRef = existingDocument.reference // Get the DocumentReference

                // Create a dictionary for the update
                let updatedData: [String: Any] = [
                    "isLiked": self.isLikedLocally,
                    "timestamp": Date().timeIntervalSince1970
                ]
                
                updateExistingLikeRecord(updatedData: updatedData, reference: documentRef) { result in
                    if !result{
                        completion(false)
                        return
                    }
                }
                
            } else {
                let likeData: [String: Any] = [
                    "userId": userId,
                    "postId": postId,
                    "isLiked": self.isLikedLocally,
                    "timestamp": Date().timeIntervalSince1970
                ]
                
                addnewLikeRecord(newData: likeData) { result in
                    if !result {
                        completion(false)
                        return
                    }
                }
                
            }
            completion(true)
        }
        
    }
    
    func addnewLikeRecord(newData: [String: Any], completion: @escaping (Bool) -> Void){
        print("new record have to be added")
        Firestore.firestore().collection("likes").document().setData(newData) { error in
            if let error = error {
                print("Error adding new like: \(error.localizedDescription)")
                completion(false)
                return
            }
            print("New like added successfully.")
            
            completion(true)
        }
    }
    
    func updateExistingLikeRecord(updatedData: [String: Any], reference documentRef: DocumentReference, completion: @escaping (_ result: Bool) -> Void){
        print("existing record found")
        documentRef.updateData(updatedData) { error in
            if let error = error {
                print("Error updating like: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    
    func startListeningForLikeCount() {

        likeCountListener = postManager.listenForLikeCount(forPostId: post.id) { [weak self] result in
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
        player?.play()
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
        player?.pause()
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
    }
    @IBAction func saveButtonTapped(_ sender: Any) {
    }
    
}

