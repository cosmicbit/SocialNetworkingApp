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
    
    func listenForLikeCount(forPost post: Post, completion: @escaping (Result<Int, Error>) -> Void) -> ListenerRegistration? {
        guard let postId = post.id else {
            return nil
        }
        let query = likesCollectionRef
            .whereField("postId", isEqualTo: postId)
            .whereField("isLiked", isEqualTo: true)
        let listener =  query.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapshot = snapshot else {
                completion(.failure(NSError(domain: "FirestoreService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Snapshot is nil."])))
                return
            }
            let currentLikeCount = snapshot.count
            Task { // Use a Task to run the async update
                do {
                    try await self.updateLikeCount(forPostId: postId, newLikeCount: currentLikeCount)
                    completion(.success(currentLikeCount)) // Only call success after the update is attempted
                } catch {
                    print("Failed to update Post's likeCount after listener change: \(error.localizedDescription)")
                    completion(.failure(error)) // Or just log and complete with success if main goal is count
                }
            }
        }
        return listener
    }
    
    private func updateLikeCount(forPostId postId: String, newLikeCount: Int) async throws {
        do {
            try await postsCollectionRef.document(postId).updateData([
                "likeCount": newLikeCount
            ])
        } catch {
            print("Error updating likeCount for post \(postId): \(error.localizedDescription)")
            throw error
        }
    }
    
    func observePosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        postsCollectionRef.order(by: "createdDate", descending: true).addSnapshotListener { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapshot = querySnapshot else {
                return
            }
            
            let posts = snapshot.documents.compactMap{ document in
                do{
                    let post = try document.data(as: Post.self)
                    return post
                }catch let decodingError as DecodingError {
                    print("Error decoding document \(document.documentID): \(decodingError.localizedDescription)")
                    return nil
                } catch {
                    print("Unknown error decoding document \(document.documentID): \(error.localizedDescription)")
                    return nil
                }
            }
            completion(.success(posts))
        }
    }
    
    func addPost(post: Post) async throws -> String{
        let newDocRef = try postsCollectionRef.addDocument(from: post)
        return newDocRef.documentID
    }
    
    func fetchPosts(limit: Int = 15) async throws -> [Post] {
        let querySnapshot = try await postsCollectionRef.limit(to: limit).getDocuments()
        let posts = querySnapshot.documents.compactMap {
            print($0.data())
            do{
                return try $0.data(as: Post.self)
            }catch{
                return nil
            }
        }
        return posts
    }
}
