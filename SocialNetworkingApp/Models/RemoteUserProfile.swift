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
    
    init(id: String, name: String, username: String, modifiedDate: Date, isOnboardingComplete: Bool, avatarImageURL: URL?, pronouns: String?, bio: String?) {
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
}
