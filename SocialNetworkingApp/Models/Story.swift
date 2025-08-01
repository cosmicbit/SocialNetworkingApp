//
//  Story.swift
//  SocialNetworkingApp
//
//  Created by Philips on 22/07/25.
//
import UIKit
import Foundation
import FirebaseFirestore

struct Story: Codable {
    @DocumentID var id: String?
    let userId: String
    let contentURL: URL
    
    enum CodingKeys: String, CodingKey{
        case id
        case userId
        case contentURL
    }
    
    init(id: String, userId: String, imageURL: URL) {
        self.id = id
        self.userId = userId
        self.contentURL = imageURL
    }
    
    init?(snapshot: QueryDocumentSnapshot) {
        let data = snapshot.data()
        let storyId = snapshot.documentID
        guard let userId = data["userId"] as? String else {
            return nil
        }
        guard let contentURL = data["contentURL"] as? URL else {
            return nil
        }
        self.id = storyId
        self.userId = userId
        self.contentURL = contentURL
    }
}
