//
//  Post.swift
//  SocialNetworkingApp
//
//  Created by Philips on 08/07/25.
//

import Foundation
import FirebaseFirestore

struct Post: Codable {
    
    @DocumentID var id: String?
    let userId: String
    let createdDate: Timestamp
    var description: String
    let type: Post.ContentType
    let contentURL: URL
    var likeCount: Int
    let size: Post.Size
    
    enum CodingKeys: String, CodingKey{
        case id
        case userId
        case createdDate
        case description
        case type
        case contentURL
        case likeCount
        case size
    }
    
    init(id: String, userId: String, createdDate: Timestamp, description: String, type: Post.ContentType, contentURL: URL, likeCount: Int, size: Post.Size) {
        self.id = id
        self.userId = userId
        self.createdDate = createdDate
        self.description = description
        self.contentURL = contentURL
        self.likeCount = likeCount
        self.type = type
        self.size = size
    }
    /*
    init?(snapshot: QueryDocumentSnapshot) {
        let data = snapshot.data()
        let postId = snapshot.documentID
        guard let userId = data["userId"] as? String else {
            return nil
        }
        guard let firebaseImageURL = data["contentURL"] as? String,
              let contentURL = URL(string:firebaseImageURL) else {
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
        guard let firebaseType = data["type"] as? String,
              let type = Post.ContentType(rawValue: firebaseType) else {
            return nil
        }
        guard let firebaseSize = data["size"] as? String,
              let size = Post.Size(rawValue: firebaseSize) else {
            return nil
        }
        let createdDate = Date(timeIntervalSince1970: timeInterval)
        self.id = postId
        self.userId = userId
        self.createdDate = createdDate
        self.description = description
        self.contentURL = contentURL
        self.likeCount = likeCount
        self.type = type
        self.size = size
    }
    
    init?(snapshot: DocumentSnapshot) {
        guard let data = snapshot.data() else {
            return nil
        }
        let postId = snapshot.documentID
        guard let userId = data["userId"] as? String else {
            return nil
        }
        guard let firebaseImageURL = data["contentURL"] as? String,
              let contentURL = URL(string:firebaseImageURL) else {
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
        guard let firebaseType = data["type"] as? String,
              let type = Post.ContentType(rawValue: firebaseType) else {
            return nil
        }
        guard let firebaseSize = data["size"] as? String,
              let size = Post.Size(rawValue: firebaseSize) else {
            return nil
        }
        let createdDate = Date(timeIntervalSince1970: timeInterval)
        self.id = postId
        self.userId = userId
        self.createdDate = createdDate
        self.description = description
        self.contentURL = contentURL
        self.likeCount = likeCount
        self.type = type
        self.size = size
    }
     */
    
    enum ContentType: String, Codable {
        case image, video, audio
    }
    
    enum Size: String, Codable {
        case square
        case landscape
        case portrait
        case reel
        
        var ratio: CGFloat {
            switch self {
            case .square:
                return 1
            case .landscape:
                return 1.91
            case .portrait:
                return 0.8 // Example value, choose what's appropriate
            case .reel:
                return 0.5625 // Example value (9:16 aspect ratio)
            }
        }
    }
}
