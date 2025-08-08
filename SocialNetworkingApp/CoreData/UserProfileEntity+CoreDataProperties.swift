//
//  UserProfileEntity+CoreDataProperties.swift
//  SocialNetworkingApp
//
//  Created by Philips on 08/08/25.
//
//

import Foundation
import CoreData


extension UserProfileEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfileEntity> {
        return NSFetchRequest<UserProfileEntity>(entityName: "UserProfileEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String
    @NSManaged public var username: String
    @NSManaged public var pronouns: String?
    @NSManaged public var bio: String?
    @NSManaged public var modifiedDate: Date
    @NSManaged public var isOnboardingComplete: Bool
    @NSManaged public var avatarImageURL: String?

}

extension UserProfileEntity : Identifiable {

}

extension UserProfileEntity {

    convenience init(from userProfile: RemoteUserProfile, in context: NSManagedObjectContext) {
        // You must call a designated initializer of NSManagedObject
        self.init(context: context)
        self.id = userProfile.id
        self.username = userProfile.username
        self.name = userProfile.name
        self.pronouns = userProfile.pronouns
        self.bio = userProfile.bio
        self.isOnboardingComplete = userProfile.isOnboardingComplete
        self.modifiedDate = userProfile.modifiedDate
        self.avatarImageURL = userProfile.avatarImageURL?.absoluteString
    }
    
    func update(with userProfile: RemoteUserProfile) {
        self.username = userProfile.username
        self.name = userProfile.name
        self.pronouns = userProfile.pronouns
        self.bio = userProfile.bio
        self.modifiedDate = userProfile.modifiedDate
        self.avatarImageURL = userProfile.avatarImageURL?.absoluteString
    }
}
