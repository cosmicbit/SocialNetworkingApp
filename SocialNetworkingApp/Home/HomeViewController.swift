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
    private let postManager = PostManager()
    private let storyManager = StoryManager()
    
    var storyHeaderView: UIView!
    var storyCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLogoLabel()
        setupPostTable()
        setupPostTableHeaderView()
        getStories()
        getPosts()
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
    
    @objc func callGoToMessagesViewController(){
        goToMessagesViewController()
    }
    
    func setupLogoLabel(){
        logoLabel.font = UIFont(name: "Pacifico-Regular", size: 25)
    }
    
    func setupPostTable(){
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        postTableView.register(nib, forCellReuseIdentifier: PostTableViewCell.identifier)
        postTableView.delegate = self
        postTableView.dataSource = self
        postTableView.estimatedRowHeight = 400
        postTableView.rowHeight = UITableView.automaticDimension
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
    
    func getStories(){
        storyManager.observePosts { result in
            switch result {
            case .success(let stories):
                self.stories = stories
                print("Stories fetched successfully. Count: \(self.stories.count)")
            case .failure(let error):
                print("Error fetching stories: \(error.localizedDescription)")
                return
            }
            self.storyCollectionView.reloadData()
        }
    }
    
    func getPosts(){
        postManager.observePosts { result in
            switch result {
            case .success(let posts):
                self.posts = posts
            case .failure(_):
                return
            }
            self.postTableView.reloadData()
        }
        
    }
    func goToMessagesViewController() {
        let homeSB = UIStoryboard(name: "Home", bundle: nil)
        let messagesVC = homeSB.instantiateViewController(withIdentifier: "MessagesViewController")
        pushTransitionDelegate = PushTransitionDelegate(withDirection: .fromRight)
        messagesVC.transitioningDelegate = pushTransitionDelegate
        messagesVC.modalPresentationStyle = .custom
        present(messagesVC, animated: true)
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
    
}

extension HomeViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = stories.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let story = stories[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StoryCollectionViewCell.identifier, for: indexPath) as! StoryCollectionViewCell
        cell.configure(userId: story.userId, hasNewStory: true)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Ensure this method is called and returns the desired size
        // It's crucial that this returns the size you want for your cells
        let desiredSize = CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
        return desiredSize
    }

    // If you need minimum line spacing (between horizontal cells)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0 // Matches your flowLayout.minimumLineSpacing = 10.0
    }

    // If you need minimum interitem spacing (between vertical rows if scroll direction was vertical)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0 // Default or adjust as needed
    }

    // If you need section insets
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 2, left: 2, bottom: 2, right: 2) // Default or adjust as needed
    }
}


