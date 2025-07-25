//
//  AcountsViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 18/07/25.
//

import UIKit

class AccountsResultsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}

extension AccountsResultsViewController: SearchResultsChildVC {
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
