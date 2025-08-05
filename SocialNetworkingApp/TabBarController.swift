//
//  TabBarController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 07/07/25.
//

import Foundation
import UIKit

var pushTransitionDelegate: PushTransitionDelegate?

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        let homeStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let homeVC = homeStoryboard.instantiateViewController(withIdentifier: "HomeViewController")
        let homeNavigationController = UINavigationController(rootViewController: homeVC)
        homeNavigationController.navigationBar.isHidden = true
        homeVC.tabBarItem.image = UIImage(systemName: "house")
        homeVC.tabBarItem.title = ""
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let exploreVC = mainStoryboard.instantiateViewController(withIdentifier: "ExploreViewController")
        let exploreNavigationController = UINavigationController(rootViewController: exploreVC)
        exploreNavigationController.navigationBar.isHidden = true
        exploreVC.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        exploreVC.tabBarItem.title = ""
        
        let postStoryboard = UIStoryboard(name: "Post", bundle: nil)
        let postVC = postStoryboard.instantiateViewController(withIdentifier: "PostViewController")
        postVC.tabBarItem.image = UIImage(systemName: "plus.app")
        postVC.tabBarItem.title = ""
        
        let accountStoryboard = UIStoryboard(name: "Account", bundle: nil)
        let accountVC = accountStoryboard.instantiateViewController(withIdentifier: "AccountViewController")
        let accountNavigationController = UINavigationController(rootViewController: accountVC)
        accountNavigationController.navigationBar.isHidden = true
        accountVC.tabBarItem.image = UIImage(systemName: "person")
        accountVC.tabBarItem.title = ""
        
        viewControllers = [homeNavigationController, exploreNavigationController, postVC, accountNavigationController]
        
    }
}


extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let selectedVC = tabBarController.selectedViewController,
              selectedVC != viewController
        else { return false }
        
        guard let controllerIndex = tabBarController.viewControllers?.firstIndex(of: viewController) else {
            return false
        }
        if controllerIndex == 2 {
            let postStoryboard = UIStoryboard(name: "Post", bundle: nil)
            let postVC = postStoryboard.instantiateViewController(withIdentifier: "PostViewController")
            pushTransitionDelegate = PushTransitionDelegate(withDirection: .fromLeft)
            postVC.transitioningDelegate = pushTransitionDelegate
            postVC.modalPresentationStyle = .custom
            selectedVC.present(postVC, animated: true)
            return false
        }
        
        return true
    }
}
