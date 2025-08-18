//
//  UserProfileManager.swift
//  SocialNetworkingApp
//
//  Created by Philips on 17/07/25.
//
import FirebaseFirestore
import os

class UserProfileManager{
    private let collectionRef = Firestore.firestore().collection("users")
    private let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
    
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
                results = docs1.compactMap{
                    do{
                        return try $0.data(as: UserProfile.self)
                    }catch{
                        return nil
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
                        results.append(contentsOf: docs2.compactMap{
                            do{
                                return try $0.data(as: UserProfile.self)
                            }catch{
                                return nil
                            }
                        })

                        let uniqueResults = Array(Set(results.map { $0.id }))
                            .compactMap { id in
                                results.first { $0.id == id }
                            }
                        completion(.success(uniqueResults))
                    }
            }
    }
    
    func getUserProfileByUserID(userId: String) async throws -> UserProfile {
        let querySnapshot = try await collectionRef.document(userId).getDocument()
        return try querySnapshot.data(as: UserProfile.self)
    }
    
    func getUserProfileByUserIDThroughCoreData(userId:String) -> UserProfile? {
        switch findUserProfileFromCoreData(userId: userId){
        case .success(let userProfileEntity):
            print("Found core data object of name: ", userProfileEntity.name)
            let userProfile = UserProfile(from: userProfileEntity)
            return userProfile
        case .failure(let error):
            let nsError = error as NSError
            if nsError.code == 404 {
                print("User profile not found. Error: \(nsError.localizedDescription)")
            } else {
                print("Failed to fetch user profile. Error: \(error.localizedDescription)")
            }
        }
        return nil
    }
    
    func getAllUsers(completion: @escaping (Result<[UserProfile], Error>) -> Void){
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
                    return try $0.data(as: UserProfile.self)
                }catch{
                    return nil
                }
            }
            completion(.success(userProfiles))
        }
    }
    
    func updateUserProfile(userProfile: UserProfile, completion: @escaping (Bool) -> Void = {_ in}){
        os_log("Updating UserProfile to firestore", type: .info)
        guard let userId = userProfile.id else {
            completion(false)
            return
        }
        do {
            try collectionRef.document(userId).setData(from: userProfile, merge: true)
            os_log("Updated UserProfile to firestore", type: .info)
            updateUserProfileToCoreData(userProfile: userProfile)
            completion(true)
        }catch{
            print(error.localizedDescription)
            completion(false)
        }
    }
    
    func addUserProfile(userProfile: UserProfile,
                        completion: @escaping(Bool) -> Void = {_ in}){
        os_log("Adding UserProfile to firestore", type: .info)
        guard let userId = userProfile.id else {
            completion(false)
            return
        }
        do {
            try collectionRef.document(userId).setData(from: userProfile, merge: true)
            os_log("Added UserProfile to firestore", type: .info)
            addUserProfileToCoreData(userProfile: userProfile)
            completion(true)
        }catch{
            print(error.localizedDescription)
            completion(false)
        }
    }
    
    func addUserProfileToCoreData(userProfile: UserProfile,
                                  completion: @escaping (Bool) -> Void = {_ in}){
        os_log("Adding UserProfile to core data stack", type: .info)
        let _ = UserProfileEntity(from: userProfile, in: managedContext)
        AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
        os_log("Added UserProfile to core data stack", type: .info)
        completion(true)
    }
    
    func updateUserProfileToCoreData(userProfile: UserProfile,
                                    completion: @escaping (Bool) -> Void = {_ in}){
        os_log("Updating UserProfile to core data stack", type: .info)
        guard let userId = userProfile.id else {
            completion(false)
            return
        }
        switch findUserProfileFromCoreData(userId: userId){
        case .success(let userProfileEntity):
            userProfileEntity.update(with: userProfile)
            AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
            os_log("Updated UserProfile to core data stack", type: .info)
        case .failure(let error):
            let nsError = error as NSError
            if nsError.code == 404 {
                os_log("Since UserProfile NOT FOUND in core data stack", type: .info)
                addUserProfileToCoreData(userProfile: userProfile)
            } else {
                os_log("Failed to fetch user profile. Error: \(error.localizedDescription)")
            }
        }
    }
    
    func findUserProfileFromCoreData(userId: String) -> Result<UserProfileEntity, Error> {
        os_log("Finding UserProfile for id: %{public}@ in core data stack", type: .info, userId)
        let fetchRequest = UserProfileEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", userId)
        
        do {
            let fetchedResults = try managedContext.fetch(fetchRequest)
            if let foundObject = fetchedResults.first {
                os_log("UserProfile FOUND for id: %{public}@ in core data stack", type: .info, userId)
                return .success(foundObject)
            } else {
                os_log("UserProfile NOT FOUND for id: %{public}@ in core data stack", type: .info)
                let error = NSError(domain: "com.SocialNetworkingApp.CoreData", code: 404, userInfo: [NSLocalizedDescriptionKey: "CoreData object not found for the given ID."])
                return .failure(error)
            }
        } catch {
            return .failure(error) // This now correctly returns the caught error
        }
    }
    
    func getAllUsernames(completion: @escaping (Result<[String], Error>) -> Void){
        var usernames: [String] = []
        collectionRef.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(.failure(error))
            }else {
                for document in querySnapshot!.documents{
                    let data = document.data()
                    if let username = data["username"] as? String{
                        usernames.append(username)
                    }
                }
                completion(.success(usernames))
            }
        }
    }
}
