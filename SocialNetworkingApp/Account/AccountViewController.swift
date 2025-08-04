//
//  AccountViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 07/07/25.
//

import UIKit
import FirebaseAuth
import SDWebImage

class AccountViewController: UIViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var shareProfileButton: UIButton!
    @IBOutlet weak var savedPostsButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    
    var userProfile: UserProfile?
    private let userProfileManager = UserProfileManager()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        getUserProfile()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditProfileSegue" {
            let destinationVC = segue.destination as! EditProfileViewController
            destinationVC.userProfile = userProfile
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        editProfileButton.layer.cornerRadius = 6
        shareProfileButton.layer.cornerRadius = 6
        savedPostsButton.layer.cornerRadius = 6
        signOutButton.layer.cornerRadius = 6
        signOutButton.layer.borderColor = UIColor.black.cgColor
        signOutButton.layer.borderWidth = 1
    }
    
    func getUserProfile() {
        Task{
            guard let userId = Auth.auth().currentUser?.uid else {
                return
            }
            do{
                userProfile = try await userProfileManager.getUserProfileByUserID(userId: userId)
            }catch{
                presentError(title: "Profile Fetch Error", message: error.localizedDescription)
            }
        }
    }
    
    func setupNavigationBar() {
        let settingsImage = UIImage(systemName: "line.3.horizontal")
        let settingsButton = UIBarButtonItem(image: settingsImage, style: .plain, target: self, action: #selector(settingsButtonTapped))
        let postImage = UIImage(systemName: "plus.app")
        let postButton = UIBarButtonItem(image: postImage, style: .plain, target: self, action: #selector(createButtonTapped))
        navigationItem.rightBarButtonItems = [settingsButton, postButton]
        navigationController?.navigationBar.tintColor = .black
    }
    
    @objc func settingsButtonTapped(){
        
    }
    
    @objc func createButtonTapped() {
        let createAlertViewController = CreateAlertViewController()
        present(createAlertViewController, animated: true)

    }
    func setupViews() {
        nameLabel.text?.removeAll()
        bioLabel.text?.removeAll()
        avatarImageView.contentMode = .scaleAspectFill
        if let userProfile = userProfile{
            avatarImageView.sd_setImage(with: userProfile.avatarImageURL)
            nameLabel.text = userProfile.name
            bioLabel.text = userProfile.bio
        }
    }
    
    @IBAction func editProfileButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "EditProfileSegue", sender: nil)
    }
    @IBAction func shareProfileButtonTapped(_ sender: Any) {
    }
    
    @IBAction func savedPostsButtonTapped(_ sender: Any) {
    }
    @IBAction func signOutButtonTapped(_ sender: Any) {
        try? Auth.auth().signOut()
        print("Logout successful")
        dismiss(animated: true)
        let authStoryboard = UIStoryboard(name: "Auth", bundle: nil)
        let loginVC = authStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
        view.window?.rootViewController = loginVC
        print("Routed back to Login View Controller")
    }
}
