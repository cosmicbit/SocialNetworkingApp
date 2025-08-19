//
//  StoryEntity+CoreDataProperties.swift
//  SocialNetworkingApp
//
//  Created by Philips on 19/08/25.
//
//

import Foundation
import CoreData


extension StoryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoryEntity> {
        return NSFetchRequest<StoryEntity>(entityName: "StoryEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var userId: String
    @NSManaged public var contentURL: String
    @NSManaged public var type: String

}

extension StoryEntity : Identifiable {

}

extension StoryEntity {

    convenience init(from story: Story, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = story.id
        self.userId = story.userId
        self.contentURL = story.contentURL.absoluteString
        self.type = story.type.rawValue
    }
}
