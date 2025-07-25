//
//  UserProfileManager.swift
//  SocialNetworkingApp
//
//  Created by Philips on 17/07/25.
//
import FirebaseFirestore

class UserProfileManager{
    
    func getUserProfilesByUsernameOrName(username: String, name: String, completion: @escaping (Result<[UserProfile], Error>) -> Void ){
        let db = Firestore.firestore()
        var prefix = username
        var endPrefix = prefix + "\u{f8ff}"

        db.collection("users")
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
                
                db.collection("users")
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
        let db = Firestore.firestore()

        db.collection("users").document(userId).getDocument(){ (snapshot, error) in
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
}
