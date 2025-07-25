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
    //var uploadTask: StorageUploadTask?
    weak var postViewControllerDelegate: PostViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadImage()
        
    }
    
    func uploadImage() {
//        guard let imageData = postToUpload.image.jpegData(compressionQuality: 0.7) else {
//            presentError(title: "Image Error", message: "Image could not be used") {
//                self.dismiss(animated: true)
//            }
//            return
//        }
        
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
        //let imagePath = "images/ \(userId)/\(imageName)"
        ImageFileManager.shared.saveImage(image: image, withName: imageName) { url, error in
            if let error = error {
                print(error.localizedDescription)
                self.presentError(title: "Upload Error", message: "Please check your internet connection.") {
                    self.dismiss(animated: true)
                }
                return
            }
            
            
            guard let downloadURL = url?.absoluteString else {
                self.presentError(title: "Upload Error", message: "Please try again later.") {
                    self.dismiss(animated: true)
                }
                return
            }
            self.progressView.setProgress(Float(0.5), animated: true)
            let postData: [String: Any] = [
                "imageURL": downloadURL,
                "description": self.postToUpload.postText,
                "userId": userId,
                "createdDate": Date().timeIntervalSince1970,
                "likeCount": 0
            ]
            self.progressView.setProgress(Float(0.75), animated: true)
            Firestore.firestore().collection("posts").document().setData(postData) { error in
                if let error = error {
                    print(error.localizedDescription)
                    self.presentError(title: "Post Error", message: "Post could not be created. Please try again later.") {
                        self.dismiss(animated: true)
                    }
                    return
                }
                self.dismiss(animated: true) {
                    self.postViewControllerDelegate?.dismissPostView()
                }
            }
            self.progressView.setProgress(Float(1), animated: true)
            
        }
        
        
        
        //let storageReference = Storage.storage().reference(withPath: imagePath)
        //let metaData = StorageMetadata()
        
        //metaData.contentType = "image/jpeg"
        /*
        uploadTask = storageReference.putData(imageData, metadata: metaData) { [weak self]_, error in
            guard let strongSelf = self else {
                return
            }
            if let error = error {
                print(error.localizedDescription)
                strongSelf.presentError(title: "Upload Error", message: "Please check your internet connection.") {
                    strongSelf.dismiss(animated: true)
                }
                return
            }
            
            storageReference.downloadURL { url, error in
                if let error = error {
                    print(error.localizedDescription)
                    strongSelf.presentError(title: "Upload Error", message: "Please try again later.") {
                        strongSelf.dismiss(animated: true)
                    }
                    return
                }
                guard let downloadURL = url?.absoluteString else {
                    strongSelf.presentError(title: "Upload Error", message: "Please try again later.") {
                        strongSelf.dismiss(animated: true)
                    }
                    return
                }
                let postData: [String: Any] = [
                    "imageURL": downloadURL,
                    "description": strongSelf.postToUpload.postText,
                    "userId": userId,
                    "createdDate": Date().timeIntervalSince1970
                ]
                
                Firestore.firestore().collection("posts").document().setData(postData) { error in
                    if let error = error {
                        print(error.localizedDescription)
                        strongSelf.presentError(title: "Post Error", message: "Post could not be created. Please try again later.") {
                            strongSelf.dismiss(animated: true)
                        }
                        return
                    }
                    strongSelf.dismiss(animated: true)
                }
            }
        }
         */
        
        /*
        uploadTask?.observe(.progress) { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            let percentComplete = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            DispatchQueue.main.async {
                strongSelf.progressView.setProgress(Float(percentComplete), animated: true)
            }
            
        }
         */
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        
        //uploadTask?.cancel()
    }
    
}
