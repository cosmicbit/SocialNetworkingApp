//
//  LikeManager.swift
//  SocialNetworkingApp
//
//  Created by Philips on 31/07/25.
//
import FirebaseFirestore
import FirebaseAuth
import Foundation

class LikeManager {
    
    private let db = Firestore.firestore()
    private let likesCollectionRef = Firestore.firestore().collection("likes")
    
    func getLikeOfUserOnPost(postId: String, userId: String, completion: @escaping (Result<Like, Error>) -> Void){
        Firestore.firestore().collection("likes")
            .whereField("userId", isEqualTo: userId)
            .whereField("postId",isEqualTo: postId)
            .getDocuments(){ [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error checking for existing reaction: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                guard let document = querySnapshot?.documents.first else {
                    print("QuerySnapshot documents were nil unexpectedly.")
                    return
                }
                guard let likeData = Like(snapshot: document) else {
                    return
                }
                completion(.success(likeData))
            }
    }
    
    func postLikeOfUserOnPost(userId:String, postId: String, likeOrNot: Bool, completion: @escaping (Bool) -> Void = { _ in }){
        Firestore.firestore().collection("likes").whereField("userId", isEqualTo: userId)
            .whereField("postId",isEqualTo: postId)
            .getDocuments(){ [weak self] querySnapshot, error in
                
            guard let self = self else {
                completion(false)
                return
            }
            if let error = error {
                print("Error checking for existing reaction: \(error.localizedDescription)")
                completion(false)
                return
            }
            guard let documents = querySnapshot?.documents else {
                print("QuerySnapshot documents were nil unexpectedly.")
                completion(false)
                return
            }
            if let existingDocument = documents.first {
                let documentRef = existingDocument.reference // Get the DocumentReference
                let updatedData: [String: Any] = [
                    "isLiked": likeOrNot,
                    "timestamp": Date().timeIntervalSince1970
                ]
                updateExistingLikeRecord(updatedData: updatedData, reference: documentRef) { result in
                    if !result{
                        completion(false)
                        return
                    }
                }
            } else {
                let likeData: [String: Any] = [
                    "userId": userId,
                    "postId": postId,
                    "isLiked": likeOrNot,
                    "timestamp": Date().timeIntervalSince1970
                ]
                addnewLikeRecord(newData: likeData) { result in
                    if !result {
                        completion(false)
                        return
                    }
                }
            }
            completion(true)
        }
    }
    
    private func addnewLikeRecord(newData: [String: Any], completion: @escaping (Bool) -> Void){
        Firestore.firestore().collection("likes").document().setData(newData) { error in
            if let error = error {
                print("Error adding new like: \(error.localizedDescription)")
                completion(false)
                return
            }
            print("New like added successfully.")
            completion(true)
        }
    }
    
    private func updateExistingLikeRecord(updatedData: [String: Any], reference documentRef: DocumentReference, completion: @escaping (_ result: Bool) -> Void){
        documentRef.updateData(updatedData) { error in
            if let error = error {
                print("Error updating like: \(error.localizedDescription)")
                completion(false)
                return
            }
            completion(true)
        }
    }
}
