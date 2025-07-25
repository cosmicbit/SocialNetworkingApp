//
//  Like.swift
//  SocialNetworkingApp
//
//  Created by Philips on 15/07/25.
//

import Foundation
import FirebaseFirestore

struct Like {
    let id: String
    let userId: String
    let postId: String
    let isLiked: Bool
    let timestamp: Date
    
    init(id: String, userId: String, postId: String, isLiked: Bool, timestamp: Date) {
        self.id = id
        self.userId = userId
        self.postId = postId
        self.isLiked = isLiked
        self.timestamp = timestamp
    }
    
    init?(snapshot: QueryDocumentSnapshot) {
        let data = snapshot.data()
        let likeId = snapshot.documentID
        guard let userId = data["userId"] as? String else {
            return nil
        }
        guard let postId = data["postId"] as? String else {
            return nil
        }
        guard let isLiked = data["isLiked"] as? Bool else {
            return nil
        }
        guard let timeInterval = data["timestamp"] as? Double
         else {
            return nil
        }
        let timestamp = Date(timeIntervalSince1970: timeInterval)
        
        self.id = likeId
        self.userId = userId
        self.postId = postId
        self.isLiked = isLiked
        self.timestamp = timestamp
    }
}
