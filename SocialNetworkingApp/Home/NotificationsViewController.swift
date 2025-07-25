//
//  NotificationsViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 23/07/25.
//

import UIKit

class NotificationsViewController: UIViewController {

    @IBOutlet weak var notificationsTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
