//
//  UserProfile+CoreDataProperties.swift
//  SocialNetworkingApp
//
//  Created by Philips on 07/08/25.
//
//

import Foundation
import CoreData


extension UserProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }

    @NSManaged public var avatarImageData: Data?
    @NSManaged public var avatarImageURL: String?
    @NSManaged public var bio: String?
    @NSManaged public var id: String?
    @NSManaged public var isOnboardingComplete: Bool
    @NSManaged public var modifiedDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var pronouns: String?
    @NSManaged public var username: String?

}

extension UserProfile : Identifiable {

}
