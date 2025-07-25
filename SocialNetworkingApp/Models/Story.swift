//
//  Story.swift
//  SocialNetworkingApp
//
//  Created by Philips on 22/07/25.
//
import UIKit
import Foundation
import FirebaseFirestore

struct Story  {
    let id: String
    let userId: String
    let imageURL: URL
    
    init(id: String, userId: String, imageURL: URL) {
        self.id = id
        self.userId = userId
        self.imageURL = imageURL
    }
    
    init?(snapshot: QueryDocumentSnapshot) {
        let data = snapshot.data()
        let storyId = snapshot.documentID
        guard let userId = data["userId"] as? String else {
            return nil
        }
        guard let firebaseImageURL = data["imageURL"] as? String,
              let imageURL = URL(string:firebaseImageURL) else {
            return nil
        }
        
        self.id = storyId
        self.userId = userId
        self.imageURL = imageURL
    }
}
