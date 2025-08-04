//
//  HomeViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 21/07/25.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var postTableView: UITableView!
    
    private var posts: [Post] = []
    private var stories: [Story] = []
    var pushTransitionDelegate: PushTransitionDelegate?
    var scaleTransitionDelegate: ScaleTransitionDelegate?
    private let postManager = PostManager()
    private let storyManager = StoryManager()
    
    var storyHeaderView: UIView!
    var storyCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLogoLabel()
        setupPostTable()
        setupPostTableHeaderView()
        Task {
            await fetchPosts()
            await fetchStories()
        }
        addLeftSwipeToView()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let headerView = postTableView.tableHeaderView else { return }
        let height = headerView.systemLayoutSizeFitting(
            CGSize(width: postTableView.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        if headerView.frame.height != height {
            headerView.frame.size.height = height
            postTableView.tableHeaderView = headerView
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        postTableView.visibleCells.forEach { ($0 as? PostTableViewCell)?.postVideoView.player?.play() }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear")
        postTableView.visibleCells.forEach { ($0 as? PostTableViewCell)?.postVideoView.player?.pause() }
    }
    
    @objc func callGoToMessagesViewController(){
        goToMessagesViewController()
    }
    
    func setupLogoLabel(){
        logoLabel.font = UIFont(name: "Pacifico-Regular", size: 25)
    }
    
    func setupPostTable(){
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        postTableView.register(nib, forCellReuseIdentifier: PostTableViewCell.identifier)
        postTableView.dataSource = self
        postTableView.estimatedRowHeight = 400
        postTableView.rowHeight = UITableView.automaticDimension
        postTableView.separatorStyle = .none
        postTableView.allowsSelection = false
        postTableView.delegate = self
    }
    
    func addLeftSwipeToView(){
        let swipeToLeft  = UISwipeGestureRecognizer(target: self, action: #selector(callGoToMessagesViewController))
        swipeToLeft.direction = .left
        view.addGestureRecognizer(swipeToLeft)
    }
    
    func setupPostTableHeaderView() {
        storyHeaderView = UIView()
        storyHeaderView.backgroundColor = .white // Match your design

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 10.0
        

        storyCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        storyCollectionView.translatesAutoresizingMaskIntoConstraints = false
        storyCollectionView.showsHorizontalScrollIndicator = false
        storyCollectionView.backgroundColor = .clear
        storyCollectionView.delegate = self
        storyCollectionView.dataSource = self

        // Register XIB for StoryCollectionViewCell
        storyCollectionView.register(StoryCollectionViewCell.self, forCellWithReuseIdentifier: StoryCollectionViewCell.identifier)

        storyHeaderView.addSubview(storyCollectionView)

        let storiesBarHeight: CGFloat = 90
        NSLayoutConstraint.activate([
            storyCollectionView.topAnchor.constraint(equalTo: storyHeaderView.topAnchor),
            storyCollectionView.bottomAnchor.constraint(equalTo: storyHeaderView.bottomAnchor),
            storyCollectionView.leadingAnchor.constraint(equalTo: storyHeaderView.leadingAnchor),
            storyCollectionView.trailingAnchor.constraint(equalTo: storyHeaderView.trailingAnchor),
            storyHeaderView.heightAnchor.constraint(equalToConstant: storiesBarHeight)
        ])

        postTableView.tableHeaderView = storyHeaderView
        storyHeaderView.frame = CGRect(x: 0, y: 0, width: postTableView.bounds.width, height: storiesBarHeight)
    }
    
    func fetchStories() async {
        do{
            let fetchedStories = try await storyManager.fetchStories()
            self.stories = fetchedStories
            DispatchQueue.main.async {
                self.storyCollectionView.reloadData()
            }
        } catch {
            print("Error fetching stories: \(error)")
        }
    }

    func fetchPosts() async {
        do {
            let fetchedPosts = try await postManager.fetchPosts()
            self.posts = fetchedPosts
            DispatchQueue.main.async {
                self.postTableView.reloadData()
            }
        } catch {
            print("Error fetching posts: \(error)")
        }
    }
    
    func goToMessagesViewController() {
        let chatSB = UIStoryboard(name: "Chat", bundle: nil)
        let chatsListVC = chatSB.instantiateViewController(withIdentifier: "ChatsListViewController")
        let chatNC = UINavigationController(rootViewController: chatsListVC)
        pushTransitionDelegate = PushTransitionDelegate(withDirection: .fromRight)
        chatNC.transitioningDelegate = pushTransitionDelegate
        chatNC.modalPresentationStyle = .custom
        chatNC.navigationBar.isHidden = true
        present(chatNC, animated: true)
    }
    
    @IBAction func notificationButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "NotificationsSegue", sender: nil)
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        goToMessagesViewController()
    }
}

extension HomeViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
        cell.configure(post: post)
        return cell
    }
}

extension HomeViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? PostTableViewCell {
            cell.postVideoView.player?.pause()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? PostTableViewCell{
            cell.postVideoView.player?.play()
        }
    }
}

extension HomeViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        stories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let story = stories[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryCollectionViewCell.identifier, for: indexPath) as! StoryCollectionViewCell
        cell.configure(userId: story.userId, hasNewStory: true)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        let cellRect = cell.frame
        let cellRectInMainView = collectionView.convert(cellRect, to: self.view)
        
        let storyVC = StoryViewController()
        scaleTransitionDelegate = ScaleTransitionDelegate(withDirection: .up, position: cellRectInMainView)
        storyVC.transitioningDelegate = scaleTransitionDelegate
        storyVC.modalPresentationStyle = .custom
        postTableView.visibleCells.forEach { ($0 as? PostTableViewCell)?.postVideoView.player?.pause() }
        present(storyVC, animated: true)
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let desiredSize = CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
        return desiredSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0 // Matches your flowLayout.minimumLineSpacing = 10.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0 // Default or adjust as needed
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 2, left: 2, bottom: 2, right: 2) // Default or adjust as needed
    }
}

extension HomeViewController: StoryViewControllerDelegate{
    func storyVCWillDismiss() {
        postTableView.visibleCells.forEach { ($0 as? PostTableViewCell)?.postVideoView.player?.play() }
    }
}
