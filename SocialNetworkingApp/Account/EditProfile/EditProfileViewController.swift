import Foundation
import UIKit
import SDWebImage
import PhotosUI


enum Axis: String {
    case x = "x", y = "y", z = "z"
}

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var avatarContainerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var actualNameButton: ProfileDetailEntryButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var actualUsernameButton: ProfileDetailEntryButton!
    @IBOutlet weak var pronounLabel: UILabel!
    @IBOutlet weak var actualPronounButton: ProfileDetailEntryButton!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var actualBioButton: ProfileDetailEntryButton!
    
    var avatarImageView = UIImageView()
    var userProfile: UserProfile!
    
    let frontImageView = UIImageView()
    let backImageView = UIImageView()
    
    
    var isFrontShowing = true
    private var isAnimating = false // Flag to prevent animation overlap
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BioSegue"{
            let destinationVC = segue.destination as! BioViewController
            destinationVC.userProfile = sender as? UserProfile
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarContainerView.layer.cornerRadius = avatarContainerView.frame.width / 2
        avatarContainerView.clipsToBounds = true
        avatarContainerView.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rotateAvatar(angleInDegrees: 360, duration: 0.5, axis: .y)
    }
    
    @objc private func didTapCustomBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    func setupNavigationBar(){
        let backImage = UIImage(systemName: "arrow.left")
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(didTapCustomBackButton))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
        navigationItem.title = "Edit Profile"
    }
    
    func setupViews() {
        if let imageURL = userProfile.avatarImageURL {
            avatarImageView.sd_setImage(with: imageURL)
        }
        setupAvatarView()
        

        actualNameButton.setTitle(userProfile.name, for: .normal)
        actualUsernameButton.setTitle(userProfile.username, for: .normal)
        
        if let pronouns = userProfile.pronouns {
            actualPronounButton.setTitle(pronouns, for: .normal)
        }
        else{
            actualPronounButton.setTitle("Pronouns", for: .disabled)
            actualPronounButton.isEnabled = false
            
            pronounLabel.isHidden = true
        }
        
        if let bio = userProfile.bio {
            actualBioButton.setTitle(bio, for: .normal)
        }
        else{
            actualBioButton.setTitle("Bio", for: .disabled)
            actualBioButton.isEnabled = false
            
            bioLabel.isHidden = true
        }
    }
    
    func setupAvatarView() {
        avatarContainerView.translatesAutoresizingMaskIntoConstraints = false
        frontImageView.image = avatarImageView.image
        backImageView.image = avatarImageView.image
        frontImageView.contentMode = .scaleAspectFill
        frontImageView.translatesAutoresizingMaskIntoConstraints = false
        frontImageView.isAccessibilityElement = true
        frontImageView.accessibilityLabel = "Profile avatar front"
        avatarContainerView.addSubview(frontImageView)
        
        NSLayoutConstraint.activate([
            frontImageView.topAnchor.constraint(equalTo: avatarContainerView.topAnchor),
            frontImageView.bottomAnchor.constraint(equalTo: avatarContainerView.bottomAnchor),
            frontImageView.leadingAnchor.constraint(equalTo: avatarContainerView.leadingAnchor),
            frontImageView.trailingAnchor.constraint(equalTo: avatarContainerView.trailingAnchor)
        ])
        
        frontImageView.layer.isDoubleSided = false
        backImageView.contentMode = .scaleAspectFill
        backImageView.translatesAutoresizingMaskIntoConstraints = false
        backImageView.isAccessibilityElement = true
        backImageView.accessibilityLabel = "Profile avatar back"
        avatarContainerView.addSubview(backImageView)
        
        NSLayoutConstraint.activate([
            backImageView.topAnchor.constraint(equalTo: avatarContainerView.topAnchor),
            backImageView.bottomAnchor.constraint(equalTo: avatarContainerView.bottomAnchor),
            backImageView.leadingAnchor.constraint(equalTo: avatarContainerView.leadingAnchor),
            backImageView.trailingAnchor.constraint(equalTo: avatarContainerView.trailingAnchor)
        ])
        
        backImageView.layer.isDoubleSided = false
        backImageView.isHidden = true
        var perspectiveTransform = CATransform3DIdentity
        perspectiveTransform.m34 = 1.0 / -500.0
        avatarContainerView.layer.transform = perspectiveTransform
    }

    func rotateAvatar(angleInDegrees: CGFloat, duration: TimeInterval, axis: Axis){
        
        let angleInRadians: CGFloat = angleInDegrees * .pi / 180
        
        // Set up perspective for 3D effect
        var perspectiveTransform = CATransform3DIdentity
        perspectiveTransform.m34 = 1.0 / -500.0
        avatarContainerView.layer.transform = perspectiveTransform
        
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.\(axis.rawValue)")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = angleInRadians
        rotationAnimation.duration = duration
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        
        // Add the animation to the layer
        avatarContainerView.layer.add(rotationAnimation, forKey: "rotate\(axis)")
        let rightAnglesInAngle = CGFloat(angleInRadians / (.pi / 2) )
        let straightAnglesInAngle = CGFloat(angleInRadians / .pi )
        let timeToCompleteOneStraightAngle = duration / straightAnglesInAngle
        let timeToCompleteOneRightAngle = duration / rightAnglesInAngle
        var durationOffset: CGFloat = timeToCompleteOneRightAngle
        while durationOffset < duration {
            DispatchQueue.main.asyncAfter(deadline: .now() + durationOffset ) {
                self.isFrontShowing.toggle()
                self.frontImageView.isHidden = !self.isFrontShowing
                self.backImageView.isHidden = self.isFrontShowing
            }
            durationOffset += timeToCompleteOneStraightAngle
        }
        
        // Ensure the final transform is set after animation completes
        CATransaction.setCompletionBlock {
            self.avatarContainerView.layer.transform = perspectiveTransform // Reset to identity with perspective
        }
    }
    
    @IBAction func changeProfileButtonTapped(_ sender: Any) {
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
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    @IBAction func actualBioButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "BioSegue", sender: userProfile)
    }
}


extension EditProfileViewController  : PHPickerViewControllerDelegate {
    
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

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            selectedImage = image
        }
        picker.dismiss(animated: true)
        
    }
}
