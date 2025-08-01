//
//  StoryViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 01/08/25.
//

import UIKit

class StoryViewController: UIViewController {
    
    private let avatar: AvatarCircleView = {
        let view = AvatarCircleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let backButton: BackButton = {
        let button = BackButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView(){
        avatar.configure(image: UIImage(systemName: "person.fill"))
        usernameLabel.text = "Philips"
        usernameLabel.textColor = .black
        subtitleLabel.text = "Hi there"
        subtitleLabel.textColor = .gray
        
        view.backgroundColor = .white
        view.addSubview(avatar)
        view.addSubview(usernameLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            avatar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            avatar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            avatar.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.07),
            avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor),
            
            usernameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            usernameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 10),
            usernameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            subtitleLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 10),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            
            backButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            backButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
    }
    
    @objc func backButtonTapped(){
        navigationController?.popViewController(animated: true)
    }

}
