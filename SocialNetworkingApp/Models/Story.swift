//
//  Story.swift
//  SocialNetworkingApp
//
//  Created by Philips on 22/07/25.
//
import Foundation
import FirebaseFirestore

struct Story: Codable {
    @DocumentID var id: String?
    let userId: String
    var contentURL: URL
    var type: Post.ContentType
    
    enum CodingKeys: String, CodingKey{
        case id
        case userId
        case contentURL
        case type
    }
    
    init(id: String, userId: String, imageURL: URL, type: Post.ContentType) {
        self.id = id
        self.userId = userId
        self.contentURL = imageURL
        self.type = type
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
        guard let typeAsString = data["type"] as? String,
              let type = Post.ContentType(rawValue: typeAsString) else {return nil}
        self.id = storyId
        self.userId = userId
        self.contentURL = contentURL
        self.type = type
    }
}
