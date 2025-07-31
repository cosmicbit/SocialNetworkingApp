//
//  PostManager.swift
//  SocialNetworkingApp
//
//  Created by Philips on 16/07/25.
//

import Foundation
import FirebaseFirestore

class PostManager{
    
    private let postsCollectionRef = Firestore.firestore().collection("posts")
    private let likesCollectionRef = Firestore.firestore().collection("likes")
    
    func listenForLikeCount(forPostId postId: String, completion: @escaping (Result<Int, Error>) -> Void) -> ListenerRegistration {
        let query = likesCollectionRef
            .whereField("postId", isEqualTo: postId)
            .whereField("isLiked", isEqualTo: true)

        return query.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let snapshot = snapshot else {
                return
            }

            let likeCount = Int(snapshot.count) 
            self.updateLikeCount(forPostId: postId, likeCount: likeCount)
            completion(.success(likeCount))
            
        }
    }
    
    private func updateLikeCount(forPostId postId: String,likeCount: Int){
        let query = postsCollectionRef.document(postId)
        let data = ["likeCount": likeCount]
        query.updateData(data) { error in
            if let _ = error {
                return
            }
        }
    }
    
    func observePosts(completion: @escaping (Result<[Post], Error>) -> Void){
        postsCollectionRef.order(by: "createdDate", descending: true).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = snapshot?.documents else {
                return
            }
            
            let posts = documents.compactMap({ Post(snapshot: $0) })
            completion(.success(posts))
        }
    }
}
