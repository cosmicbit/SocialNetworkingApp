//
//  PostViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 07/07/25.
//

import UIKit
import Photos
import PhotosUI

protocol PostViewControllerDelegate: AnyObject{
    func dismissPostView()
    
}
class PostViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    let placeholderText = "Whats's on yout mind?"
    var selectedImage: UIImage? {
        didSet {
            if selectedImage != nil {
                previewImageView.image = selectedImage
                cameraImageView.isHidden = true
            }
            else {
                previewImageView.image = nil
                cameraImageView.isHidden = false
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UploadImageAndPostSegue" {
            let destinationVC = segue.destination as! UploadImageAndPostViewController
            let postToUpload = sender as! PostToUpload
            destinationVC.postToUpload = postToUpload
            destinationVC.postViewControllerDelegate = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        previewImageView.contentMode = .scaleAspectFill
        
        setupContainerView()
        setupDescriptionTextView()
        
        addBackGroundTap()
        
        addLeftSwipeToView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.layer.cornerRadius = 8
        descriptionTextView.layer.cornerRadius = 6
    }
    
    @objc func endtextViewEditing() {
        view.endEditing(true)
    }
    
    @objc func goBack(){
        dismiss(animated: true)
    }
    
    func setupContainerView(){
        containerView.backgroundColor = UIColor.lightGray
        containerView.clipsToBounds = true
        let containerTap = UITapGestureRecognizer(target: self, action: #selector(showCameraOptions))
        containerView.addGestureRecognizer(containerTap)
        containerView.isUserInteractionEnabled = true
    }
    
    func setupDescriptionTextView() {
        descriptionTextView.delegate = self
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.text = placeholderText
    }
    
    func addBackGroundTap(){
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(endtextViewEditing))
        view.addGestureRecognizer(viewTap)
        view.isUserInteractionEnabled = true
    }
    
    func addLeftSwipeToView(){
        let swipeToLeft = UISwipeGestureRecognizer(target: self, action: #selector(goBack))
        swipeToLeft.direction = .left
        view.addGestureRecognizer(swipeToLeft)
    }
    
    func selected(image: UIImage) {
        previewImageView.image = image
        cameraImageView.isHidden = true
    }
    
    @objc func showCameraOptions() {
        let alert = UIAlertController(title: "Choose Image Source", message: "Attach an image to your post", preferredStyle: .actionSheet)
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

    @IBAction func postButtonTapped(_ sender: Any) {
        guard let selectedImage = selectedImage else {
            presentError(title: "Image Required", message: "Please attach an image with your post.")
            return
        }
        guard descriptionTextView.textColor != .lightGray else {
            presentError(title: "Description Required", message: "Please write a valid post description.")
            return
        }
        
       
        guard  let postText = descriptionTextView.text,
               postText.count > 5 && postText.count < 60 else {
                   presentError(title: "Post text Error ", message: "Please ensure the number of charcters in your post test is greater than 5 and less than 60.")
                   return
        }
        let postToUpload = PostToUpload(image: selectedImage, postText: postText)
        performSegue(withIdentifier: "UploadImageAndPostSegue", sender: postToUpload)
    }
    
}

extension PostViewController: PHPickerViewControllerDelegate {
    
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

extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            selectedImage = image
        }
        picker.dismiss(animated: true)
        
    }
}

extension PostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionTextView.textColor == .lightGray {
            descriptionTextView.text = ""
            descriptionTextView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionTextView.text == "" {
            descriptionTextView.textColor = UIColor.lightGray
            descriptionTextView.text = placeholderText
        }
    }
}

extension PostViewController: PostViewControllerDelegate {
    func dismissPostView() {
        dismiss(animated: true)
    }
    
    
}
