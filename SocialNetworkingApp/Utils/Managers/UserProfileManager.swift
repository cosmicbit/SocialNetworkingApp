//
//  UserProfileManager.swift
//  SocialNetworkingApp
//
//  Created by Philips on 17/07/25.
//
import FirebaseFirestore

class UserProfileManager{
    private let collectionRef = Firestore.firestore().collection("users")
    private let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
    
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
    
    func getUserProfileByUserID(userId: String) async throws -> RemoteUserProfile {
        let querySnapshot = try await collectionRef.document(userId).getDocument()
        return try querySnapshot.data(as: RemoteUserProfile.self)
    }
    
    func getUserProfileByUserIDThroughCoreData(userId:String) -> RemoteUserProfile? {
        let fetchRequest = UserProfile.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", userId)
        do {
            // Execute the fetch request
            let fetchedResults = try managedContext.fetch(fetchRequest)

            if let foundObject = fetchedResults.first {
                print("Found object with custom ID: \(foundObject)")
                print("Found odject of name: ", foundObject.name)
                var url: URL?
                if let urlString = foundObject.avatarImageURL{
                    url = URL(string: urlString)
                }
                let userProfile = RemoteUserProfile(
                    id: foundObject.id,
                    name: foundObject.name,
                    username: foundObject.username,
                    modifiedDate: foundObject.modifiedDate,
                    isOnboardingComplete: foundObject.isOnboardingComplete,
                    avatarImageURL: url,
                    pronouns: foundObject.pronouns,
                    bio: foundObject.bio
                )
                return userProfile
            } else {
                print("Object not found.")
            }
        } catch {
            print("Failed to fetch object: \(error)")
        }
        return nil
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
    
    func updateUserProfile(userProfile: RemoteUserProfile, completion: @escaping (Bool) -> Void = {_ in}){
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
    
    func addUserProfile(userProfile: RemoteUserProfile,
                        completion: @escaping(Bool) -> Void = {_ in}){
        guard let userId = userProfile.id else {
            completion(false)
            return
        }
        do {
            try collectionRef.document(userId).setData(from: userProfile, merge: true)
            addUserProfileToCoreData(userProfile: userProfile)
            completion(true)
        }catch{
            print(error.localizedDescription)
            completion(false)
        }
    }
    
    func addUserProfileToCoreData(userProfile: RemoteUserProfile,
                                  completion: @escaping (Bool) -> Void = {_ in}){
        
        let newUserProfile = UserProfile(context: managedContext)
        newUserProfile.id = userProfile.id
        newUserProfile.name = userProfile.name
        newUserProfile.username = userProfile.username
        newUserProfile.pronouns = userProfile.pronouns
        newUserProfile.bio = userProfile.bio
        newUserProfile.isOnboardingComplete = userProfile.isOnboardingComplete
        newUserProfile.modifiedDate = userProfile.modifiedDate
        newUserProfile.avatarImageURL = userProfile.avatarImageURL?.absoluteString
        AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
        completion(true)
    }
    
    func updateUserProfileToCoreData(userProfile: RemoteUserProfile,
                                    completion: @escaping (Bool) -> Void = {_ in}){
        guard let userId = userProfile.id else {
            completion(false)
            return
        }
        let fetchRequest = UserProfile.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", userId)
        do {
            let fetchedResults = try managedContext.fetch(fetchRequest)

            if let foundObject = fetchedResults.first {
                print("Found core data object of name: ", foundObject.name)
                foundObject.name = userProfile.name
                foundObject.username = userProfile.username
                foundObject.pronouns = userProfile.pronouns
                foundObject.bio = userProfile.bio
                foundObject.modifiedDate = userProfile.modifiedDate
                foundObject.avatarImageURL = userProfile.avatarImageURL?.absoluteString
                AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
            } else {
                print("Object not found in core data.")
                addUserProfileToCoreData(userProfile: userProfile)
            }
        } catch {
            print("Failed to fetch object: \(error)")
        }
    }
    
    
}
