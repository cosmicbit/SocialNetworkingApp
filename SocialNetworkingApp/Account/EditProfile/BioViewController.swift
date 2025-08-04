//
//  BioViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 04/08/25.
//

import UIKit

class BioViewController: UIViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bioCaptionLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var bioLimitLabel: UILabel!
    
    private let BIO_CHARACTER_LIMIT = 150
    var userProfile: UserProfile!
    private let userProfileManager = UserProfileManager()
    var bioCharacterCount: Int = 0{
        didSet{
            bioLimitLabel.text = "\(BIO_CHARACTER_LIMIT - bioCharacterCount)/150"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.layer.borderWidth = 2
        containerView.layer.cornerRadius = 8
    }
    
    func setupView(){
        bioTextView.text = userProfile.bio
        bioCharacterCount = bioTextView.text.count
        bioTextView.textContainerInset = .zero
        bioTextView.textContainer.lineFragmentPadding = .zero
        
        saveButton.tintColor = .link
        saveButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Unsaved changes", message: "You have unsaved changes. Are you sure you want to cancel?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .cancel) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        let noAction = UIAlertAction(title: "No", style: .default)
        alert.addAction(noAction)
        alert.addAction(yesAction)
        present(alert, animated: true)
    }
    @IBAction func saveButtonTapped(_ sender: Any) {
        userProfile.bio = bioTextView.text
        saveButton.setImage(UIImage(systemName: "circle"), for: .normal)
        userProfileManager.updateUserProfile(userProfile: userProfile) { result in
            self.saveButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            if result{
                self.navigationController?.popViewController(animated: true)
            }else{
                self.showToast(message: "Something went wrong. Try again")
            }
            
        }
    }
}
extension BioViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        bioCharacterCount = textView.text.count
    }
}
