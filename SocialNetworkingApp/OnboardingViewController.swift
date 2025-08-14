//
//  OnboardingViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 08/07/25.
//

import UIKit
import PhotosUI
import FirebaseFirestore
import FirebaseAuth

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var avatarContainerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var uploadAvatarButton: UIButton!
    @IBOutlet weak var createProfileButton: UIButton!
    
    private let userProfileManager = UserProfileManager()
    var selectedImage: UIImage? = nil {
        didSet {
            if selectedImage != nil {
                avatarImageView.image = selectedImage
            }
            else {
                avatarImageView.image = nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @objc func endTextFieldEditing() {
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarContainerView.layer.cornerRadius = avatarContainerView.frame.width / 2
        uploadAvatarButton.layer.borderWidth = 2
        uploadAvatarButton.layer.cornerRadius = 6
        uploadAvatarButton.layer.borderColor = UIColor.link.cgColor
        
        createProfileButton.layer.cornerRadius = 12
        createProfileButton.layer.shadowColor = UIColor.black.cgColor
        createProfileButton.layer.shadowOpacity = 0.5
        createProfileButton.layer.shadowRadius = 4
        createProfileButton.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    func setupView(){
        uploadAvatarButton.backgroundColor = .white
        uploadAvatarButton.setTitleColor(.link, for: .normal)
        avatarImageView.contentMode = .scaleAspectFill
        avatarContainerView.clipsToBounds = true
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(endTextFieldEditing))
        view.addGestureRecognizer(viewTap)
        view.isUserInteractionEnabled = true
    }

    @IBAction func uploadAvatarButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Choose Image Source", message: "Attach an image to your avatar", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                self.present(imagePicker, animated: true)
            }
            else {
                print("No camera available for this device")
                self.presentError(title: "Camera not found", message: "This device has no camera. Please try again with a different device with camera")
            }
            
        }
        let libraryAction = UIAlertAction(title: "Library", style: .default) { _ in
            var phPickerConfiguration = PHPickerConfiguration(photoLibrary: .shared())
            phPickerConfiguration.filter = PHPickerFilter.any(of: [.images])
            let phPickerViewController = PHPickerViewController(configuration: phPickerConfiguration)
            phPickerViewController.delegate = self
            self.present(phPickerViewController, animated: true)
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            
        }
        
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        
    }
    
    @IBAction func createProfileButtonTapped(_ sender: Any) {
        guard let name = nameTextField.text,
              !name.isEmpty else {
            presentError(title: "Name Field Empty!", message: "Please add your name")
            return
        }
        guard let username = usernameTextField.text,
              !username.isEmpty else {
            presentError(title: "Username Field Empty!", message: "Please add a username")
            return
        }
        guard let userId = Auth.auth().currentUser?.uid else {
            presentError(title: "Sign In", message: "You need to be signed in to upload an image") {
                self.dismiss(animated: true)
            }
            return
        }
        if selectedImage != nil{
            guard let avatarImage = avatarImageView.image else {
                presentError(title: "Image Error", message: "Please add an image to continue")
                return
            }
            let imageId = UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "_")
            let imageName = imageId + ".jpeg"
            
            ImageFileManager.shared.saveImage(image: avatarImage, withName: imageName) { url, error in
                if let error = error {
                    print(error.localizedDescription)
                    self.presentError(title: "Upload Error", message: "Please check your internet connection.") {
                        self.dismiss(animated: true)
                    }
                    return
                }
                
                let userProfile = UserProfile(
                    id: userId,
                    name: name,
                    username: username,
                    modifiedDate: Date(),
                    isOnboardingComplete: true,
                    avatarImageURL: url,
                    pronouns: nil,
                    bio: nil
                )
                self.userProfileManager.addUserProfile(userProfile: userProfile) { result in
                    if result{
                        self.dismiss(animated: true)
                    }
                }
            }
        }
        else{
            let userProfile = UserProfile(
                id: userId,
                name: name,
                username: username,
                modifiedDate: Date(),
                isOnboardingComplete: true,
                avatarImageURL: nil,
                pronouns: nil,
                bio: nil
            )
            self.userProfileManager.addUserProfile(userProfile: userProfile) { result in
                if result{
                    self.dismiss(animated: true)
                }
            }
        }
        view.window?.rootViewController = TabBarController()
    }
}

extension OnboardingViewController  : PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if let result = results.first{
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                if let error = error {
                    print(error.localizedDescription)
                    DispatchQueue.main.async {
                        self.presentError(title: "Image error", message: "Could Not load image")
                    }
                    
                    return
                }
                guard let image = reading as? UIImage else {
                    
                    self.presentError(title: "Image error", message: "Could Not load image")
                    return
                }
                DispatchQueue.main.async {
                    self.selectedImage = image
                }
            }
        }
    }
}

extension OnboardingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            selectedImage = image
        }
        picker.dismiss(animated: true)
        
    }
}
