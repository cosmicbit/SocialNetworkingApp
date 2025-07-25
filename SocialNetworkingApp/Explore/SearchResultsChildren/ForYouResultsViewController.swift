//
//  ForYouViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 18/07/25.
//

import UIKit

class ForYouResultsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension ForYouResultsViewController: SearchResultsChildVC {
    var searchQuery: String? {
        get {
            return ""
        }
        set {
            
        }
    }
    
    func refreshResults() {
        
    }
    
    
}
