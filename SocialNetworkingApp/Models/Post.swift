//
//  Post.swift
//  SocialNetworkingApp
//
//  Created by Philips on 08/07/25.
//

import Foundation
import FirebaseFirestore

struct Post {
    let id: String
    let userId: String
    let createdDate: Date
    let description: String
    let imageURL: URL
    let likeCount: Int
    
    init(id: String, userId: String, createdDate: Date, description: String, imageURL: URL, likeCount: Int) {
        self.id = id
        self.userId = userId
        self.createdDate = createdDate
        self.description = description
        self.imageURL = imageURL
        self.likeCount = likeCount
    }
    
    
    init?(snapshot: QueryDocumentSnapshot) {
        let data = snapshot.data()
        let postId = snapshot.documentID
        guard let userId = data["userId"] as? String else {
            return nil
        }
        guard let firebaseImageURL = data["imageURL"] as? String,
              let imageURL = URL(string:firebaseImageURL) else {
            return nil
        }
        guard let description = data["description"] as? String else {
            return nil
        }
        guard let timeInterval = data["createdDate"] as? Double
         else {
            return nil
        }
        guard let likeCount = data["likeCount"] as? Int else {
            return nil
        }
        let createdDate = Date(timeIntervalSince1970: timeInterval)
        self.id = postId
        self.userId = userId
        self.createdDate = createdDate
        self.description = description
        self.imageURL = imageURL
        self.likeCount = likeCount
        
    }
    
    init?(snapshot: DocumentSnapshot) {
        guard let data = snapshot.data() else {
            return nil
        }
        let postId = snapshot.documentID
        guard let userId = data["userId"] as? String else {
            return nil
        }
        guard let firebaseImageURL = data["imageURL"] as? String,
              let imageURL = URL(string:firebaseImageURL) else {
            return nil
        }
        guard let description = data["description"] as? String else {
            return nil
        }
        guard let timeInterval = data["createdDate"] as? Double
         else {
            return nil
        }
        guard let likeCount = data["likeCount"] as? Int else {
            return nil
        }
        let createdDate = Date(timeIntervalSince1970: timeInterval)
        self.id = postId
        self.userId = userId
        self.createdDate = createdDate
        self.description = description
        self.imageURL = imageURL
        self.likeCount = likeCount
        
    }
}
