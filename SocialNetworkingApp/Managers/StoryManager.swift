//
//  StoryManager.swift
//  SocialNetworkingApp
//
//  Created by Philips on 22/07/25.
//

import Foundation
import FirebaseFirestore

class StoryManager{
    
    func observePosts(completion: @escaping (Result<[Story], Error>) -> Void){
        Firestore.firestore().collection("stories").addSnapshotListener { snapshot, error in
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
}
