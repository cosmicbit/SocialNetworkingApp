//
//  UserProfileManager.swift
//  SocialNetworkingApp
//
//  Created by Philips on 17/07/25.
//
import FirebaseFirestore

class UserProfileManager{
    private let collectionRef = Firestore.firestore().collection("users")
    
    func getUserProfilesByUsernameOrName(username: String, name: String, completion: @escaping (Result<[RemoteUserProfile], Error>) -> Void ){
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

                var results: [RemoteUserProfile] = []
                guard let docs1 = snapshot1?.documents else {
                    return
                }
                docs1.forEach { doc in
                    if let userProfile = RemoteUserProfile(snapshot: doc){
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
                            if let userProfile = RemoteUserProfile(snapshot: doc){
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
    
    func getUserProfileByUserID(userId:String) async throws -> RemoteUserProfile{
        let querySnapshot = try await collectionRef.document(userId).getDocument()
        return try querySnapshot.data(as: RemoteUserProfile.self)
    }
    
    func getAllUsers(completion: @escaping (Result<[RemoteUserProfile], Error>) -> Void){
        collectionRef.getDocuments { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let documents = querySnapshot?.documents else {
                completion(.failure(NSError(domain: "FirestoreService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Snapshot is nil"])))
                return
            }
            let userProfiles = documents.compactMap {
                do{
                    return try $0.data(as: RemoteUserProfile.self)
                }catch{
                    return nil
                }
            }
            completion(.success(userProfiles))
        }
    }
    
    func updateUserProfile(userProfile: RemoteUserProfile, completion: @escaping (Bool) -> Void){
        guard let userId = userProfile.id else {
            completion(false)
            return
        }
        do {
            try collectionRef.document(userId).setData(from: userProfile, merge: true)
            completion(true)
        }catch{
            print(error.localizedDescription)
            completion(false)
        }
    }
}
