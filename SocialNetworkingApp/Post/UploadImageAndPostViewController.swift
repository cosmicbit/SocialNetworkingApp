//
//  UploadImageAndPostViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 07/07/25.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore
 

class UploadImageAndPostViewController: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    var postToUpload: PostToUpload!
    weak var postViewControllerDelegate: PostViewControllerDelegate?
    private let postManager = PostManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadImage()
        
    }
    
    func uploadImage() {
        guard let userId = Auth.auth().currentUser?.uid else {
            presentError(title: "Sign In", message: "You need to be signed in to upload an image") {
                self.dismiss(animated: true)
            }
            return
        }
        progressView.progress = 0
        let image = postToUpload.image
        let imageId = UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "_")
        let imageName = imageId + ".jpeg"
        ImageFileManager.shared.saveImage(image: image, withName: imageName) { [weak self] url, error in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                self.presentError(title: "Upload Error", message: "Please check your internet connection.") {
                    self.dismiss(animated: true)
                }
                return
            }
            guard let URL = url else {
                self.presentError(title: "Upload Error", message: "Please try again later.") {
                    self.dismiss(animated: true)
                }
                return
            }
            self.progressView.setProgress(Float(0.5), animated: true)
            let newPost = Post(userId: userId, createdDate: Timestamp(), description: self.postToUpload.postText, type: .image, contentURL: URL, size: .portrait)
            self.progressView.setProgress(Float(0.75), animated: true)
            
            Task {
                do {
                    let newPostID = try await self.postManager.addPost(post: newPost)
                    print("New post added with ID: \(newPostID)")
                    self.dismiss(animated: true){
                        self.postViewControllerDelegate?.dismissPostView()
                    }
                } catch {
                    print("Error adding post: \(error)")
                    self.presentError(title: "Post Error", message: "Post could not be created. Please try again later.") {
                        self.dismiss(animated: true)
                    }
                }
            }
            self.progressView.setProgress(Float(1), animated: true)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
