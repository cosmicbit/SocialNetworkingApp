//
//  RemoteUserProfile.swift
//  SocialNetworkingApp
//
//  Created by Philips on 09/07/25.
//

import Foundation
import FirebaseFirestore

struct RemoteUserProfile: Codable {
    @DocumentID var id: String?
    var name: String
    var username: String
    var pronouns: String?
    var bio: String?
    let modifiedDate: Date
    let isOnboardingComplete: Bool
    var avatarImageURL: URL?
    
    init(id: String?, name: String, username: String, modifiedDate: Date, isOnboardingComplete: Bool, avatarImageURL: URL?, pronouns: String?, bio: String?) {
        self.id = id
        self.name = name
        self.username = username
        self.modifiedDate = modifiedDate
        self.isOnboardingComplete = isOnboardingComplete
        self.avatarImageURL = avatarImageURL
        self.pronouns = pronouns
        self.bio = bio
    }
    
    init?(snapshot: DocumentSnapshot){
        let id = snapshot.documentID
        guard let data = snapshot.data() else {
            return nil
        }
        guard let name = data["name"] as? String else {
            return nil
        }
        guard let username = data["username"] as? String else {
            return nil
        }
        guard let timeInterval = data["modifiedDate"] as? Double else {
            return nil
        }
        guard let isOnboardingComplete = data["isOnboardingComplete"] as? Bool else {
            return nil
        }
        
        if let firebaseAvatarImageURL = data["avatarImageURL"] as? String,
            let avatarImageURL = URL(string: firebaseAvatarImageURL) {
                self.avatarImageURL = avatarImageURL
        }
        else{
            self.avatarImageURL = nil
        }
        self.pronouns = data["pronouns"] as? String
        self.bio = data["bio"] as? String
        self.id = id
        self.name = name
        self.username = username
        self.modifiedDate = Date(timeIntervalSince1970: timeInterval)
        self.isOnboardingComplete = isOnboardingComplete
        
    }
    
    init?(snapshot: QueryDocumentSnapshot){
        let id = snapshot.documentID
        let data = snapshot.data()
        
        guard let name = data["name"] as? String else {
            return nil
        }
        guard let username = data["username"] as? String else {
            return nil
        }
        guard let timeInterval = data["modifiedDate"] as? Double else {
            return nil
        }
        guard let isOnboardingComplete = data["isOnboardingComplete"] as? Bool else {
            return nil
        }
        
        if let firebaseAvatarImageURL = data["avatarImageURL"] as? String,
            let avatarImageURL = URL(string: firebaseAvatarImageURL) {
                self.avatarImageURL = avatarImageURL
        }
        else{
            self.avatarImageURL = nil
        }
        self.pronouns = data["pronouns"] as? String
        self.bio = data["bio"] as? String
        
        self.id = id
        self.name = name
        self.username = username
        self.modifiedDate = Date(timeIntervalSince1970: timeInterval)
        self.isOnboardingComplete = isOnboardingComplete
        
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._id = try container.decode(DocumentID<String>.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.username = try container.decode(String.self, forKey: .username)
        self.pronouns = try container.decodeIfPresent(String.self, forKey: .pronouns)
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
        self.modifiedDate = try container.decode(Date.self, forKey: .modifiedDate)
        self.isOnboardingComplete = try container.decode(Bool.self, forKey: .isOnboardingComplete)
        self.avatarImageURL = try container.decodeIfPresent(URL.self, forKey: .avatarImageURL)
    }
    init(from userProfile: UserProfileEntity){
        self.id = userProfile.id
        self.name = userProfile.name
        self.username = userProfile.username
        self.pronouns = userProfile.pronouns
        self.bio = userProfile.bio
        self.modifiedDate = userProfile.modifiedDate
        self.isOnboardingComplete = userProfile.isOnboardingComplete
        guard let avatarImageURL = userProfile.avatarImageURL else {
            return
        }
        self.avatarImageURL = URL(string: avatarImageURL)
    }
}
