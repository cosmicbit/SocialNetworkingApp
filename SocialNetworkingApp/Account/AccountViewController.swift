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
        if segue.identifier == "ShareSegue"{
            let destinationVC = segue.destination as! ShareViewController
            destinationVC.userProfile = userProfile
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupUserProfile()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserProfileUpdate(_:)), name: NSNotification.Name("UserProfileDidUpdate"), object: nil)
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
    @objc func handleUserProfileUpdate(_ notification: Notification){
        if let userProfile = notification.userInfo?["userProfile"] as? UserProfile{
            self.userProfile = userProfile
        }
        setupUserProfile()
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

    func setupViews() {
        nameLabel.text?.removeAll()
        bioLabel.text?.removeAll()
        avatarImageView.contentMode = .scaleAspectFill
    }
    
    func setupUserProfile(){
        guard let userProfile = userProfile else{
            return
        }
        avatarImageView.sd_setImage(with: userProfile.avatarImageURL)
        nameLabel.text = userProfile.name
        bioLabel.text = userProfile.bio
    }
    
    @IBAction func createButtonTapped(_ sender: Any) {
        let createAlertViewController = CreateAlertViewController()
        present(createAlertViewController, animated: true)
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func editProfileButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "EditProfileSegue", sender: nil)
    }
    @IBAction func shareProfileButtonTapped(_ sender: Any) {
        let shareSB = UIStoryboard(name: "Share", bundle: .main)
        let shareVC = shareSB.instantiateViewController(withIdentifier: "ShareViewController") as! ShareViewController
        shareVC.userProfile = userProfile
        let navC = UINavigationController(rootViewController: shareVC)
        navC.modalPresentationStyle = .overFullScreen
        present(navC, animated: true)
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
