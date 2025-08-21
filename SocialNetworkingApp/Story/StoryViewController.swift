//
//  StoryViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 01/08/25.
//

import UIKit

protocol StoryViewControllerDelegate: AnyObject{
    func storyVCWillDismiss()
}

class StoryViewController: UIViewController {
    var identitifier : Int!
    var originalCenterOfView: CGPoint = CGPoint()
    weak var delegate: StoryViewControllerDelegate?
    var story: StoryEntity!
    var remainingStories: [StoryEntity]!
    var storyUserProfile: UserProfile?
    private let userProfileManager = UserProfileManager()
    private let totalStoryDuration: TimeInterval = 10.0 // 10 seconds per story
    private var progressTimer: Timer?
    private var startTime: Date?
    private var pausedTime: TimeInterval = 0.0
    var isDismissedByTimer: Bool = false
    
    private var panGesture: UIPanGestureRecognizer?
    private var upSwipeGesture: UISwipeGestureRecognizer?
    var interactiveAnimator: UIPercentDrivenInteractiveTransition?
    var translatedByPan: CGFloat = 0
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startProgressTimer()
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
        // Stop any existing timer to prevent duplicates
        progressTimer?.invalidate()

        // Adjust the start time to account for any paused duration
        startTime = Date().addingTimeInterval(-pausedTime)

        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self, let startTime = self.startTime else {
                timer.invalidate()
                return
            }
            
            // Use the adjusted startTime for accurate progress calculation
            let elapsedTime = Date().timeIntervalSince(startTime)
            let progress = Float(elapsedTime / self.totalStoryDuration)
            
            self.progressView.progress = progress
            
            if progress >= 1.0 {
                // Invalidate the timer once progress is complete
                timer.invalidate()
                self.pausedTime = 0.0 // Reset paused time for the next story
                // ➡️ Your existing logic for next story or dismissal goes here...
                if remainingStories.count >= 1 {
                    let newVC = StoryViewController()
                    newVC.story = remainingStories[0]
                    newVC.identitifier = self.identitifier + 1
                    remainingStories.removeFirst()
                    newVC.remainingStories = remainingStories
                    if var viewControllers = navigationController?.viewControllers {
                        viewControllers.removeLast()
                        viewControllers.append(newVC)
                        navigationController?.setViewControllers(viewControllers, animated: true)
                    }
                } else {
                    self.navigationController?.transitioningDelegate = nil
                    self.navigationController?.modalTransitionStyle = .coverVertical
                    self.navigationController?.modalPresentationStyle = .overFullScreen
                    self.dismiss(animated: true) {
                        self.delegate?.storyVCWillDismiss()
                    }
                }
            }
        }
    }
    
    private func pauseProgressTimer() {
        // 1. Invalidate the current timer to stop it
        progressTimer?.invalidate()
        
        // 2. Calculate and store the elapsed time
        if let startTime = self.startTime {
            self.pausedTime += Date().timeIntervalSince(startTime)
        }
        
        // 3. Reset startTime to nil to prevent unwanted updates
        self.startTime = nil
    }
    
    func addPanGesture(){
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureOfView(_:)))
        if let pan = panGesture{
            pan.delegate = self
            navigationController?.view.addGestureRecognizer(pan)
        }
        upSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleUpSwipe(_: )))
        if let upSwipe = upSwipeGesture{
            upSwipe.direction = .up
            upSwipe.delegate = self
            view.addGestureRecognizer(upSwipe)
        }
    }
    /*
    @objc func handlePanGestureOfView(_ sender: UIPanGestureRecognizer){
        if sender.state == .began{
            pauseProgressTimer()
        }
        guard let draggedView = sender.view else { return }
        let translation = sender.translation(in: self.view)
        let newCenter = CGPoint(x: draggedView.center.x, y: draggedView.center.y + translation.y * 0.5)
        
        draggedView.center = newCenter
        sender.setTranslation(.zero, in: self.view)
        print("og center - ", originalCenterOfView)
        print("new center - ", draggedView.center)
        
        if sender.state == .ended {
            startProgressTimer()
            if draggedView.center.y < originalCenterOfView.y{
                draggedView.center = originalCenterOfView
            }else{
                dismiss(animated: true){
                    self.delegate?.storyVCWillDismiss()
                }
            }
        }
    }
     */
    
    @objc func handlePanGestureOfView(_ sender: UIPanGestureRecognizer){
        //print(sender.state)
        guard let navigationView = sender.view else { return }
        let translation = sender.translation(in: navigationView)
        //print("translation: ", translation.x)
        let loc = sender.location(in: navigationView)
        //print("location : ", loc)
        let percentage = abs(translation.x) / navigationView.bounds.width
        //print("percentage : ",percentage)
        let progress = min(1.0, max(0, percentage))
        //print("progress : ", progress)
        
        switch sender.state{
        case .began:
            pauseProgressTimer()
            interactiveAnimator = UIPercentDrivenInteractiveTransition()
            //print("number of remaining stories : ", remainingStories.count)
            if remainingStories.count > 0 {
                let newVC = StoryViewController()
                newVC.story = remainingStories[0]
                newVC.identitifier = self.identitifier + 1
                let newstories = Array(remainingStories[1...])
                print(newstories.count)
                newVC.remainingStories = newstories
                print("VC id during beginning: ", self.identitifier)
                navigationController?.setViewControllers([newVC, self], animated: false)
                navigationController?.popViewController(animated: true)
//
//                
//                if var viewControllers = navigationController?.viewControllers {
//                    viewControllers.removeLast()
//                    viewControllers.append(newVC)
//                    navigationController?.setViewControllers(viewControllers, animated: true)
//                }
                
                
            }else{
                self.navigationController?.transitioningDelegate = nil
                self.navigationController?.modalTransitionStyle = .coverVertical
                self.navigationController?.modalPresentationStyle = .overFullScreen
                self.dismiss(animated: true) {
                    self.delegate?.storyVCWillDismiss()
                }
            }
        case .changed:
            interactiveAnimator?.update(progress)
        case .ended, .cancelled:
            //print("final progress : ", progress)
            if progress > 0.3{
                //print("finished")
                interactiveAnimator?.finish()
            }else{
                print("VC id during cancelletion: ", self.identitifier)
                interactiveAnimator?.cancel()
                navigationController?.setViewControllers([self], animated: true)
            }
            interactiveAnimator = nil
        default:
            break
        }
        //sender.setTranslation(.zero, in: self.view)
    }
    
    @objc func handleUpSwipe(_ sender: UISwipeGestureRecognizer){
        print("Swiped in up direction")
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

extension StoryViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //if operation == .push {
            return CubeTransitionAnimator(isPresenting: true, withDuration: 0.5)
        //}
        //return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveAnimator
    }
}

extension StoryViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGesture && otherGestureRecognizer == upSwipeGesture{
            return true
        }
        return false
    }
}

extension StoryViewController: UIViewControllerTransitioningDelegate{
    
}
