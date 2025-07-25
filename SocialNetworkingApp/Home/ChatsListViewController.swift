//
//  MessagesViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 23/07/25.
//

import UIKit

class ChatsListViewController: UIViewController {
    
    
    @IBOutlet weak var messagesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupMessagesTableHeader()
        addRightSwipeToView()
        
    }
    
    
    
    @objc func backToHomeVC(){
        dismiss(animated: true)
    }
    
    func setupMessagesTableHeader() {
        let messagesTableHeaderView = ChatsTableHeaderView(frame: CGRect(x: 0, y: 0, width: messagesTableView.bounds.width, height: 0))
        
        messagesTableHeaderView.translatesAutoresizingMaskIntoConstraints = false
        let headerHeight = messagesTableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height

        messagesTableView.tableHeaderView = messagesTableHeaderView
        NSLayoutConstraint.activate([
            messagesTableHeaderView.heightAnchor.constraint(equalToConstant: headerHeight),
            messagesTableHeaderView.leadingAnchor.constraint(equalTo: messagesTableView.leadingAnchor),
            messagesTableHeaderView.trailingAnchor.constraint(equalTo: messagesTableView.trailingAnchor),
            messagesTableHeaderView.widthAnchor.constraint(equalTo: messagesTableView.widthAnchor, multiplier: 1)
        ])
        
        messagesTableHeaderView.frame = CGRect(x: 0, y: 0, width: messagesTableView.bounds.width, height: headerHeight)
    }
    
    func addRightSwipeToView(){
        let swipeToRight = UISwipeGestureRecognizer(target: self, action: #selector(backToHomeVC))
        swipeToRight.direction = .right
        view.addGestureRecognizer(swipeToRight)
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func usernameButtonTapped(_ sender: Any) {
    }
    @IBAction func aiStudioButtonTapped(_ sender: Any) {
    }
    @IBAction func newMessageButtonTapped(_ sender: Any) {
    }
    

}


