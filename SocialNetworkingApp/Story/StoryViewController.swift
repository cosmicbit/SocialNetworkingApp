//
//  StoryViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 01/08/25.
//

import UIKit

protocol StoryViewControllerDelegate: AnyObject{
    func storyVCWillDismiss()
}

class StoryViewController: UIViewController {
    
    var originalCenterOfView: CGPoint = CGPoint()
    weak var delegate: StoryViewControllerDelegate?
    
    private let avatar: AvatarCircleView = {
        let view = AvatarCircleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
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
        addPanGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.cornerRadius = 12
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
        
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            avatar.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            avatar.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10),
            avatar.heightAnchor.constraint(equalToConstant: 45),
            avatar.widthAnchor.constraint(equalToConstant: 45),
            
            usernameLabel.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
            usernameLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 10),
            usernameLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            
            subtitleLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 10),
            subtitleLabel.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10),
            
            backButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            backButton.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
        ])
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        originalCenterOfView = view.center
    }
    
    func addPanGesture(){
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureOfView(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handlePanGestureOfView(_ sender: UIPanGestureRecognizer){
        guard let draggedView = sender.view else { return }
        let translation = sender.translation(in: self.view)
        let newCenter = CGPoint(x: draggedView.center.x, y: draggedView.center.y + translation.y * 0.5)
        if newCenter.y > originalCenterOfView.y {
            draggedView.center = newCenter
        }
        sender.setTranslation(.zero, in: self.view)
        if sender.state == .ended{
            dismiss(animated: true)
        }
    }
    
    @objc func backButtonTapped(){
        dismiss(animated: true)
    }

}
