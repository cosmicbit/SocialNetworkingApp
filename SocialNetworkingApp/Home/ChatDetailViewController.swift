//
//  ChatDetailViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 25/07/25.
//

import UIKit

class ChatDetailViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func backButtonTapped(_ sender: Any){
        dismiss(animated: true)//navigationController?.popViewController(animated: true)
    }
}
