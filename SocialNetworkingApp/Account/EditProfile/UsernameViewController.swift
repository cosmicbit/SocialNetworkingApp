//
//  UsernameViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 18/08/25.
//

import UIKit

class UsernameViewController: UIViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var usernameCaptionLabel: UILabel!
    @IBOutlet weak var usernameTextView: UITextView!
    @IBOutlet weak var usernameValidityCheckingIndicatorView: UIActivityIndicatorView!
    
    var userProfile: UserProfile!
    private let userProfileManager = UserProfileManager()
    var keyboardHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { (notification) in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
            self.keyboardHeight = keyboardFrame.cgRectValue.height
            print("keyboardHeight", self.keyboardHeight)
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { (_) in
            self.keyboardHeight = 0
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.layer.borderColor = UIColor.black.cgColor
        containerView.layer.borderWidth = 2
        containerView.layer.cornerRadius = 8
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupView(){
        usernameTextView.text = userProfile.username
        usernameTextView.textContainerInset = .zero
        usernameTextView.textContainer.lineFragmentPadding = .zero
        usernameTextView.delegate = self
        saveButton.setTitleColor(.lightGray, for: .disabled)
        saveButton.setTitleColor(.link, for: .normal)
    }
    
    func isUsernameValid(username: String, completion: @escaping (Error?) -> Void){
        let errorDomain = "com.socialnetworkingapp.error"
        if username == userProfile.username{
            completion(nil)
            return
        }
        if username.last == "."{
            completion(NSError(
                domain: errorDomain, code: 1, userInfo: [
                    NSLocalizedDescriptionKey: "You can't end your username with a period."
                ]))
            return
        }
        if username.count == 1{
            completion(NSError(
                domain: errorDomain, code: 1, userInfo: [
                    NSLocalizedDescriptionKey: "The username is not available for use in instagram. Please try a different one."
                ]))
            return
        }
        if username.first == "."{
            completion(NSError(
                domain: errorDomain, code: 1, userInfo: [
                    NSLocalizedDescriptionKey: "You can't start your username with a period."
                ]))
            return
        }
        userProfileManager.getAllUsernames { result in
            switch result {
            case .success(let usernames):
                let isValid = !usernames.contains(username)
                completion(isValid ? nil : NSError(
                    domain: errorDomain, code: 1, userInfo: [
                        NSLocalizedDescriptionKey: "The username \(username) is not available."
                    ]))
            case .failure( _):
                completion(NSError(
                    domain: errorDomain, code: 1, userInfo: [
                        NSLocalizedDescriptionKey: "Unable to fetch usernames at the moment."
                    ]))
            }
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any){
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func saveButtonTapped(_ sender: Any){
        userProfile.username = usernameTextView.text
        saveButton.setImage(UIImage(systemName: "circle"), for: .normal)
        userProfileManager.updateUserProfile(userProfile: userProfile) { result in
            self.saveButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            if result, let userProfile = self.userProfile{
                let userInfo: [String: Any] = ["userProfile": userProfile]
                NotificationCenter.default.post(name: NSNotification.Name("UserProfileDidUpdate"), object: nil, userInfo: userInfo)
                self.navigationController?.popViewController(animated: true)
            }else{
                self.showToast(message: "Something went wrong. Try again")
            }
        }
    }
}

extension UsernameViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        usernameValidityCheckingIndicatorView.startAnimating()
        saveButton.isEnabled = false
        guard let username = textView.text else { return }
        let count = username.count
        if(count > 30){
            textView.text = String(username.prefix(30))
        }
        isUsernameValid(username: username) { error in
            self.usernameValidityCheckingIndicatorView.stopAnimating()
            if let error = error{
                self.showToast(message: error.localizedDescription, bottomConstraintConstant: -self.keyboardHeight - 10)
                return
            }
            self.saveButton.isEnabled = true
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == " " {
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: "_")
            textView.text = newText
            return false
        }
        return true
    }
}
