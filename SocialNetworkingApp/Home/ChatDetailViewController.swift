//
//  ChatDetailViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 25/07/25.
//

import UIKit

class ChatDetailViewController: UIViewController {

    @IBOutlet weak var backButton: BackButton!
    @IBOutlet weak var otherUserAvatarView: AvatarCircleView!
    @IBOutlet weak var otherUserNameButton: UIButton!
    
    private var tableView: UITableView!
    private var messageBar: MessageBarView!
    
    var otherUserProfile: UserProfile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        setupTopBar()
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
    }
    
    func setupTopBar(){

        otherUserAvatarView.imageView.sd_setImage(with: otherUserProfile.avatarImageURL)
        var config = UIButton.Configuration.plain()
        config.title = otherUserProfile.name
        config.subtitle = otherUserProfile.username
        config.titlePadding = 4.0
        
   
        var titleAttributes = AttributeContainer()
        titleAttributes.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        config.attributedTitle = AttributedString(config.title!, attributes: titleAttributes)

        var subtitleAttributes = AttributeContainer()
        subtitleAttributes.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subtitleAttributes.foregroundColor = .lightGray
        config.attributedSubtitle = AttributedString(config.subtitle!, attributes: subtitleAttributes)
        otherUserNameButton.configuration = config
    }
    

    @IBAction func backButtonTapped(_ sender: Any){
        navigationController?.popViewController(animated: true)
    }
}
