//
//  HomeViewController.swift
//  SocialNetworkingApp
//
//

import UIKit
import FirebaseFirestore
import SDWebImage

class ExploreViewController: UIViewController {
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let numberOfItemsPerRow: CGFloat = 3
    let spacing: CGFloat = 3
    let searchController = UISearchController(searchResultsController: nil)
    var posts : [Post] = []
    
    
    lazy var cellWidth: CGFloat = {
        let availableWidth = collectionView.bounds.width - (CGFloat(numberOfItemsPerRow - 1) * spacing)
        let cellWidth: CGFloat = availableWidth / numberOfItemsPerRow
        return cellWidth
    }()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ExplorePostSegue"{
            let destinationVC = segue.destination as! ExplorePostViewController
            let post = sender as! Post
            destinationVC.post = post
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        observePosts()
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumInteritemSpacing = spacing
        }
        addTapGestureToSearchView()
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchView.layer.cornerRadius = searchView.bounds.height / 2
    }
   
    
    func addTapGestureToSearchView(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(searchViewTapped))
        tap.isEnabled = true
        searchView.addGestureRecognizer(tap)
    }
    
    @objc func searchViewTapped(){
        performSegue(withIdentifier: "SearchSegue", sender: nil)
    }
    
    func observePosts() {
        Firestore.firestore().collection("posts").order(by: "createdDate", descending: true).addSnapshotListener { [weak self] snapshot, error in
            guard let strongSelf = self else {
                return
            }
            if let _ = error {
                strongSelf.presentError(title: "Posts Error", message: "Cannot retrieve posts.")
                return
            }
            guard let documents = snapshot?.documents else {
                return
            }
            strongSelf.posts.removeAll()
            strongSelf.posts = documents.compactMap({ Post(snapshot: $0) })
            strongSelf.collectionView.reloadData()
        }
    }

}

extension ExploreViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let post = posts[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        cell.postImageView.sd_setImage(with: post.contentURL)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        performSegue(withIdentifier: "ExplorePostSegue", sender: post)
    }
}


extension ExploreViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
extension ExploreViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    }
}

extension ExploreViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    }
}
