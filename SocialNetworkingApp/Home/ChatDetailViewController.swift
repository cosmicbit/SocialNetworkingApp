//
//  ChatDetailViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 25/07/25.
//

import UIKit

class ChatDetailViewController: UIViewController {

    @IBOutlet weak var backButton: BackButton!
    
    private var tableView: UITableView!
    private var messageBar: MessageBarView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        messageBar = MessageBarView()
        messageBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageBar)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: backButton.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageBar.topAnchor),
            messageBar.heightAnchor.constraint(equalToConstant: 50),
            messageBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            messageBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            messageBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5)
        ])
        
        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func backButtonTapped(_ sender: Any){
        navigationController?.popViewController(animated: true)
    }
}
