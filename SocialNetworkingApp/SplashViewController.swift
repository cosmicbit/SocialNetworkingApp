//
//  SplashViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 08/07/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let window = view.window
        guard let userId = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("error occured")
                print(error.localizedDescription)
                try? Auth.auth().signOut()
                let authStoryboard = UIStoryboard(name: "Auth", bundle: nil)
                let loginVC = authStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
                window?.rootViewController = loginVC
                return
            }
            guard let snapshot = snapshot else {
                print("Snapshot is nil")
                try? Auth.auth().signOut()
                let authStoryboard = UIStoryboard(name: "Auth", bundle: nil)
                let loginVC = authStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
                window?.rootViewController = loginVC
                return
            }
            
            guard snapshot.exists else {
                print("Snapshot does not exist")
                try? Auth.auth().signOut()
                let authStoryboard = UIStoryboard(name: "Auth", bundle: nil)
                let loginVC = authStoryboard.instantiateViewController(withIdentifier: "LoginViewController")
                window?.rootViewController = loginVC
                return
            }
            guard let data = snapshot.data(),
            let isOnboardingComplete = data["isOnboardingComplete"] as? Bool else {
                print("data is nil or data ")
                return
            }
            if isOnboardingComplete {
                window?.rootViewController = TabBarController()
            } else {
                let onboardingStoryboard = UIStoryboard(name: "Onboarding", bundle: nil)
                let onboardingViewController = onboardingStoryboard.instantiateViewController(withIdentifier: "OnboardingViewController")
                window?.rootViewController = onboardingViewController
            }
        }
    }

}
