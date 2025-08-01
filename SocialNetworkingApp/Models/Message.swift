//
//  Message.swift
//  SocialNetworkingApp
//
//  Created by Philips on 25/07/25.
//

import Foundation
import FirebaseFirestore

// MARK: - Message Model

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    let senderId: String
    let content: String
    let timestamp: Timestamp
    let type: String
    var imageUrl: URL?
    var fileUrl: URL?
    var fileName: String?
    var readBy: [String]
    var isEdited: Bool?
    var editedAt: Timestamp?

    enum CodingKeys: String, CodingKey {
        case id
        case senderId
        case content
        case timestamp
        case type
        case imageUrl
        case fileUrl
        case fileName
        case readBy
        case isEdited
        case editedAt
    }

    init(senderId: String, content: String, type: String = "text", imageUrl: URL? = nil, fileUrl: URL? = nil, fileName: String? = nil) {
        self.senderId = senderId
        self.content = content
        self.timestamp = Timestamp(date: Date())
        self.type = type
        self.imageUrl = imageUrl
        self.fileUrl = fileUrl
        self.fileName = fileName
        self.readBy = [senderId]
        self.isEdited = false
        self.editedAt = nil
    }
}

