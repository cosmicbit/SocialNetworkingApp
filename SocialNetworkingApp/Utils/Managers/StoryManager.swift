//
//  StoryManager.swift
//  SocialNetworkingApp
//
//  Created by Philips on 22/07/25.
//

import Foundation
import FirebaseFirestore

class StoryManager{
    private let storiesCollestionRef = Firestore.firestore().collection("stories")
    
    func observePosts(completion: @escaping (Result<[Story], Error>) -> Void){
        storiesCollestionRef.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                return
            }
            
            let stories = documents.compactMap({ Story(snapshot: $0) })
            completion(.success(stories))
        }
    }
    
    func addStory(story: Story) async throws -> String{
        let newDocRef = try storiesCollestionRef.addDocument(from: story)
        return newDocRef.documentID
    }
    
    func fetchStories(limit: Int = 15) async throws -> [Story] {
        let querySnapshot = try await storiesCollestionRef.limit(to: limit).getDocuments()
        let stories = querySnapshot.documents.compactMap {
            do{
                return try $0.data(as: Story.self)
            }catch{
                return nil
            }
        }
        return stories
    }
}
