//
//  Chat.swift
//  SocialNetworkingApp
//
//  Created by Philips on 25/07/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Chat Model

struct Chat: Identifiable, Codable {
    var id: String?
    let participants: [String]
    var participantNames: [String]?
    var lastMessage: LastMessage?
    var updatedAt: Timestamp
    let createdAt: Timestamp

    enum CodingKeys: String, CodingKey {
        case id
        case participants
        case participantNames
        case lastMessage
        case updatedAt
        case createdAt
    }

    struct LastMessage: Codable {
        let senderId: String
        let content: String
        let timestamp: Timestamp
        let type: String
        var imageUrl: URL?
        var fileUrl: URL?
    }

    init(participants: [String], participantNames: [String]? = nil) {
        let sortedParticipants = participants.sorted()
        self.id = sortedParticipants.joined(separator: "_")
        self.participants = sortedParticipants
        self.participantNames = participantNames
        let now = Timestamp(date: Date())
        self.updatedAt = now
        self.createdAt = now
        self.lastMessage = nil
    }
    
//    init?(snapshot: DocumentSnapshot){
//        guard let data = snapshot.data() else {
//            return nil
//        }
//        let chatId = snapshot.documentID
//        guard let userId = data["userId"] as? String else {
//            return nil
//        }
//        guard let firebaseImageURL = data["imageURL"] as? String,
//              let imageURL = URL(string:firebaseImageURL) else {
//            return nil
//        }
//        guard let description = data["description"] as? String else {
//            return nil
//        }
//        guard let timeInterval = data["createdDate"] as? Double
//         else {
//            return nil
//        }
//        guard let likeCount = data["likeCount"] as? Int else {
//            return nil
//        }
//        let createdDate = Date(timeIntervalSince1970: timeInterval)
//        self.id = chatId
//        self.userId = userId
//        self.createdDate = createdDate
//        self.description = description
//        self.imageURL = imageURL
//        self.likeCount = likeCount
//    }
}
