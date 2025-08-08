//
//  UserProfile+CoreDataProperties.swift
//  SocialNetworkingApp
//
//  Created by Philips on 08/08/25.
//
//

import Foundation
import CoreData


extension UserProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile")
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

extension UserProfile : Identifiable {

}
