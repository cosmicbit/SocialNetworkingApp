//
//  UserProfileManager.swift
//  SocialNetworkingApp
//
//  Created by Philips on 17/07/25.
//
import FirebaseFirestore

class UserProfileManager{
    //private let db = Firestore.firestore()
    private let collectionRef = Firestore.firestore().collection("users")
    
    func getUserProfilesByUsernameOrName(username: String, name: String, completion: @escaping (Result<[UserProfile], Error>) -> Void ){
        var prefix = username
        var endPrefix = prefix + "\u{f8ff}"

        collectionRef
            .whereField("username", isGreaterThanOrEqualTo: prefix)
            .whereField("username", isLessThan: endPrefix)
            .limit(to: 5)
            .getDocuments { (snapshot1, error1) in
                if let error1 = error1 {
                    completion(.failure(error1))
                    return
                }

                var results: [UserProfile] = []
                guard let docs1 = snapshot1?.documents else {
                    return
                }
                docs1.forEach { doc in
                    if let userProfile = UserProfile(snapshot: doc){
                        results.append(userProfile)
                    }
                }
                prefix = name
                endPrefix = prefix + "\u{f8ff}"
                
                self.collectionRef
                    .whereField("name", isGreaterThanOrEqualTo: prefix)
                    .whereField("name", isLessThan: endPrefix)
                    .limit(to: 5)
                    .getDocuments { (snapshot2, error2) in
                        if let error2 = error2 {
                            completion(.failure(error2))
                            return
                        }

                        guard let docs2 = snapshot2?.documents else {
                            return
                        }
                        docs2.forEach { doc in
                            if let userProfile = UserProfile(snapshot: doc){
                                results.append(userProfile)
                            }
                        }

                        let uniqueResults = Array(Set(results.map { $0.id }))
                            .compactMap { id in
                                results.first { $0.id == id }
                            }
                        completion(.success(uniqueResults))
                    }
            }
    }
    
    func getUserProfileByUserID(userId:String, completion: @escaping (Result<UserProfile, Error>) -> Void ){

        collectionRef.document(userId).getDocument(){ (snapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let doc = snapshot else {
                return
            }
               
            guard let userProfile = UserProfile(snapshot: doc) else{
                return
            }
            completion(.success(userProfile))
        }
    }
    
    func getAllUsers(completion: @escaping (Result<[UserProfile], Error>) -> Void){
        collectionRef.getDocuments { querySnapshot, error in

            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = querySnapshot?.documents else {
                return
            }
            let userProfiles = documents.compactMap { UserProfile(snapshot: $0) }
            completion(.success(userProfiles))
        }
    }
}
