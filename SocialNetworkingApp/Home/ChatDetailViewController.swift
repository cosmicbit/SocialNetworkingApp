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
    private var messageBarBottomConstraint: NSLayoutConstraint!
    
    var otherUserProfile: UserProfile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupKeyboardObservers()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
    }
    
    func setupView(){
        setupTopBar()
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        messageBar = MessageBarView()
        messageBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageBar)
        messageBarBottomConstraint = messageBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: backButton.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageBar.topAnchor),
            messageBar.heightAnchor.constraint(equalToConstant: 50),
            messageBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            messageBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5),
            messageBarBottomConstraint
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
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    // Call this method typically from viewWillDisappear(_:) or deinit
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }


    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }

        let safeAreaBottomInset = view.safeAreaInsets.bottom // Account for safe area
        let keyboardHeight = keyboardFrame.height
        
        messageBarBottomConstraint.constant = -(keyboardHeight - safeAreaBottomInset)
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
            self.view.layoutIfNeeded() // Animate the layout change
        }, completion: nil)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }

        messageBarBottomConstraint.constant = -10

        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
            self.view.layoutIfNeeded() // Animate the layout change
        }, completion: nil)
    }
    

    @IBAction func backButtonTapped(_ sender: Any){
        navigationController?.popViewController(animated: true)
    }
}
