//
//  ExplorePostViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 18/07/25.
//

import UIKit

class ExplorePostViewController: UIViewController {
    @IBOutlet weak var explorePostTableView: UITableView!
    
    var post: Post!
    var otherPosts: [Post] = []
    private let postManager = PostManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register the NIB (XIB) for your custom cell
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        explorePostTableView.register(nib, forCellReuseIdentifier: "PostTableViewCell")
        explorePostTableView.delegate = self
        explorePostTableView.dataSource = self
        getOtherPosts()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let cells = explorePostTableView.visibleCells
        for cell in cells {
            if let cell = cell as? PostTableViewCell {
                cell.player?.play()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let cells = explorePostTableView.visibleCells
        for cell in cells {
            if let cell = cell as? PostTableViewCell {
                cell.player?.pause()
            }
        }
    }
    
    func getOtherPosts(){
        postManager.observePosts { result in
            switch result {
            case .success(let posts):
                self.otherPosts = posts.filter({ post in
                    post.id != self.post.id
                })
                self.explorePostTableView.reloadData()
            case .failure(_):
                return
            }
        }
        
    }
    

    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    

}

extension ExplorePostViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + otherPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var post: Post
        post = indexPath.row == 0 ? self.post : otherPosts[indexPath.row - 1]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
        cell.configure(post: post)
        return cell
    }
    
    
}
extension ExplorePostViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? PostTableViewCell {
            cell.player?.pause()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? PostTableViewCell{
            cell.player?.play()
        }
    }
}
