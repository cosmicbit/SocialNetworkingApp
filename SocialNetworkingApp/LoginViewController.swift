//
//  LoginViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 07/07/25.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func loginWithGoogleButtonTapped(_ sender: Any) {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        if GIDSignIn.sharedInstance.hasPreviousSignIn(){
            GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
                guard let strongSelf = self else {return}
                if let error = error {
                    print(error.localizedDescription)
                    strongSelf.presentError(title: "Login Failed", message: "Something went wrong. Please try again later.")
                    return
                }
                guard let user = user else {
                    strongSelf.presentError(title: "Login Failed", message: "Something went wrong. Please try again later.")
                    return
                }
                strongSelf.authenticate(user: user)
            }
        }
        else{
            
            GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
                
                guard let strongSelf = self else {return}
                
                if let error = error {
                    print(error.localizedDescription)
                    strongSelf.presentError(title: "Login Failed", message: "Something went wrong. Please try again later.")
                    return
                }
                
                guard let user = result?.user else {
                    strongSelf.presentError(title: "Login Failed", message: "Something went wrong. Please try again later.")
                    return
                }
                strongSelf.authenticate(user: user)
            }
        }
    }
    
    func authenticate(user: GIDGoogleUser) {
        guard let idToken = user.idToken?.tokenString else {
            presentError(title: "Login Failed", message: "Something went wrong. Please try again later.")
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
        
        Auth.auth().signIn(with: credential) { [weak self]result, error in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.presentError(title: "Login Failed", message: "Something went wrong. Please try again later.")
                print(error.localizedDescription)
                return
            }
            
            
            let window = strongSelf.view.window
            
            guard let userId = Auth.auth().currentUser?.uid else {
                strongSelf.presentError(title: "Login Failed", message: "Something went wrong. Please try again later.")
                return
            }
            
            Firestore.firestore().collection("users").document(userId).getDocument { snapshot, error in
                if let error = error {
                    strongSelf.presentError(title: "Login Failed", message: "Something went wrong. Please try again later.")
                    print(error.localizedDescription)
                    return
                }
                guard let snapshot = snapshot else {
                    strongSelf.presentError(title: "Login Failed", message: "Something went wrong. Please try again later.")
                    return
                }
                
                guard snapshot.exists else {
                    print("snapshot does not exist")
                    Firestore.firestore().collection("users").document(userId).setData(["isOnboardingComplete": false]){
                        error in
                        if let error = error {
                            strongSelf.presentError(title: "Login Failed", message: "Something went wrong. Please try again later.")
                            print(error.localizedDescription)
                            return
                        }
                        let onboardingStoryboard = UIStoryboard(name: "Onboarding", bundle: nil)
                        let onboardingViewController = onboardingStoryboard.instantiateViewController(withIdentifier: "OnboardingViewController")
                        window?.rootViewController = onboardingViewController
                        
                    }
                    return
                }
                
                guard let data = snapshot.data(),
                let isOnboardingComplete = data["isOnboardingComplete"] as? Bool else { return }
                if isOnboardingComplete {
                    print("Routing to LoginVC to TabBarC")
                    window?.rootViewController = TabBarController()
                } else {
                    print("Routing to LoginVC to OnboardingVC")
                    let onboardingStoryboard = UIStoryboard(name: "Onboarding", bundle: nil)
                    let onboardingViewController = onboardingStoryboard.instantiateViewController(withIdentifier: "OnboardingViewController")
                    window?.rootViewController = onboardingViewController
                }
            }
            
        }
    }
    

}
