//
//  StoryViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 01/08/25.
//

import UIKit

protocol StoryViewControllerDelegate: AnyObject{
    func storyVCWillDismiss()
    func storyDidFinish()
}

class StoryViewController: UIViewController {
    
    var originalCenterOfView: CGPoint = CGPoint()
    weak var delegate: StoryViewControllerDelegate?
    var story: StoryEntity!
    var remainingStories: [StoryEntity]!
    var storyUserProfile: UserProfile?
    private let userProfileManager = UserProfileManager()
    private let totalStoryDuration: TimeInterval = 3.0 // 10 seconds per story
    private var progressTimer: Timer?
    private var startTime: Date?
    var isDismissedByTimer: Bool = false
    
    private let progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .default)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.progressTintColor = .white
        view.trackTintColor = .lightGray
        return view
    }()
    
    private let avatar: AvatarCircleView = {
        let view = AvatarCircleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mediaDisplayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var storyImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    var storyVideoView: VideoContainerView = {
        let view = VideoContainerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        if let _ = storyUserProfile{
            setupStoryUserProfile()
        }
        getStoryUserProfile()
        setupStory()
        addPanGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.cornerRadius = 12
        storyVideoView.playerLayer?.frame = storyVideoView.bounds
    }
    
    func setupView(){
        view.backgroundColor = .black
        subtitleLabel.text = "Ayakiya laila"
        view.addSubview(mediaDisplayView)
        mediaDisplayView.addSubview(storyImageView)
        mediaDisplayView.addSubview(storyVideoView)
        view.addSubview(progressView)
        view.addSubview(avatar)
        view.addSubview(usernameLabel)
        view.addSubview(subtitleLabel)
        
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            mediaDisplayView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            mediaDisplayView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            mediaDisplayView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            mediaDisplayView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            storyImageView.topAnchor.constraint(equalTo: mediaDisplayView.topAnchor),
            storyImageView.bottomAnchor.constraint(equalTo: mediaDisplayView.bottomAnchor),
            storyImageView.leadingAnchor.constraint(equalTo: mediaDisplayView.leadingAnchor),
            storyImageView.trailingAnchor.constraint(equalTo: mediaDisplayView.trailingAnchor),
            storyVideoView.topAnchor.constraint(equalTo: mediaDisplayView.topAnchor),
            storyVideoView.bottomAnchor.constraint(equalTo: mediaDisplayView.bottomAnchor),
            storyVideoView.leadingAnchor.constraint(equalTo: mediaDisplayView.leadingAnchor),
            storyVideoView.trailingAnchor.constraint(equalTo: mediaDisplayView.trailingAnchor),
            
            progressView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            progressView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            avatar.topAnchor.constraint(equalTo: progressView.topAnchor, constant: 10),
            avatar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            avatar.heightAnchor.constraint(equalToConstant: 40),
            avatar.widthAnchor.constraint(equalToConstant: 40),
            
            usernameLabel.centerYAnchor.constraint(equalTo: avatar.centerYAnchor, constant: -10),
            usernameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 10),
            usernameLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            
            subtitleLabel.centerYAnchor.constraint(equalTo: avatar.centerYAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 10),
            subtitleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
        ])
        storyImageView.isHidden = true
        storyVideoView.isHidden = true
        
        originalCenterOfView = view.center
    }
    
    private func getStoryUserProfile() {
        let userId = story.userId
        Task{
            do{
                storyUserProfile = try await userProfileManager.getUserProfileByUserID(userId: userId)
                setupStoryUserProfile()
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    private func setupStoryUserProfile(){
        if let imageURL = storyUserProfile?.avatarImageURL {
            avatar.configure(imageURL: imageURL)
        }
        usernameLabel.text = storyUserProfile?.username
    }
    
    func setupStory(){
        guard let type = Post.ContentType(rawValue: story.type),
              let url = URL(string: story.contentURL)
        else {return}
        displayMedia(type: type, mediaURL: url)
        startProgressTimer()
    }
    
    private func displayMedia(type: Post.ContentType, mediaURL: URL?) {
        storyVideoView.player?.pause()
        storyVideoView.playerLayer?.removeFromSuperlayer()
        storyVideoView.playerLayer = nil
        storyVideoView.removePlayerObservers() // Remove observers from previous player/item
        storyImageView.sd_cancelCurrentImageLoad() // Cancel any ongoing image downloads
        storyVideoView.isHidden = true
        storyImageView.isHidden = true
        guard let url = mediaURL else {
            print("Error: Media type selected but no URL provided. Displaying placeholder.")
            storyImageView.isHidden = false
            storyImageView.image = UIImage(systemName: "photo.fill.on.rectangle.fill")
            storyImageView.contentMode = .scaleAspectFit
            return
        }
        switch type {
        case .video:
            storyVideoView.isHidden = false
            storyVideoView.setupVideoPlayer(with: url)
            view.setNeedsLayout()
            view.layoutIfNeeded()
        case .image:
            storyImageView.sd_setImage(with: url)
            storyImageView.contentMode = .scaleAspectFit
            storyImageView.isHidden = false
        case .audio:
            storyImageView.isHidden = false
            storyImageView.image = UIImage(systemName: "waveform")
            storyImageView.contentMode = .scaleAspectFit
        }
    }
    
    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressView.progress = 0.0
        startTime = Date()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self, let startTime = self.startTime else {
                timer.invalidate()
                return
            }
            let elapsedTime = Date().timeIntervalSince(startTime)
            let progress = Float(elapsedTime / self.totalStoryDuration)
            self.progressView.progress = progress
            if progress >= 1.0 {
                timer.invalidate()
                self.transitioningDelegate = self
                self.modalPresentationStyle = .fullScreen
                self.dismiss(animated: true){
                    self.delegate?.storyDidFinish()
                }
            }
        }
    }
    
    func addPanGesture(){
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureOfView(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handlePanGestureOfView(_ sender: UIPanGestureRecognizer){
        guard let draggedView = sender.view else { return }
        let translation = sender.translation(in: self.view)
        let newCenter = CGPoint(x: draggedView.center.x, y: draggedView.center.y + translation.y * 0.5)
        if newCenter.y > originalCenterOfView.y {
            draggedView.center = newCenter
        }
        sender.setTranslation(.zero, in: self.view)
        if sender.state == .ended{
            dismiss(animated: true){
                self.delegate?.storyVCWillDismiss()
            }
        }
    }
    
    deinit {
        storyVideoView.player?.pause()
        storyVideoView.player = nil
        storyVideoView.playerLayer?.removeFromSuperlayer()
        storyVideoView.playerLayer = nil
        storyVideoView.removePlayerObservers()
        progressTimer?.invalidate()
    }
}

extension StoryViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        CubeTransitionAnimator(isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        CubeTransitionAnimator(isPresenting: false)
    }
}
