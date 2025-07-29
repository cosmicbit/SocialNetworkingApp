//
//  ChatDetailViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 25/07/25.
//

import UIKit
import FirebaseAuth


class ChatDetailViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var backButton: BackButton!
    @IBOutlet weak var otherUserAvatarView: AvatarCircleView!
    @IBOutlet weak var otherUserNameButton: UIButton!
    
    // MARK: - Private variables
    private var tableView: UITableView!
    private var messageBar: MessageBarView!
    private var messageBarBottomConstraint: NSLayoutConstraint!
    private var currentUserId: String?
    private var chatManager = ChatManager()
    private var userProfileManager = UserProfileManager()
    private var messages: [Message] = []
    
    // MARK: - Public variables
    var otherUserProfile: UserProfile!
    
    //MARK: - Overloaded functions
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCurrentUserId()
        setupView()
        setupKeyboardObservers()
        startListening()
        chatManager.delegate = self
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObservers()
        chatManager.detachListeners()
        
    }
    
    // MARK: - init functions
    func setupView(){
        setupTopBar()
        setupTableView()
        setupMessageBar()
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
    
    func setupTableView(){
        tableView = UITableView()
        tableView.register(ChatDetailTableViewCell.self, forCellReuseIdentifier: ChatDetailTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        //tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.separatorStyle = .none
        view.addSubview(tableView)
    }
    
    func setupMessageBar(){
        messageBar = MessageBarView()
        messageBar.cameraButton.backgroundColor = .purple
        messageBar.translatesAutoresizingMaskIntoConstraints = false
        messageBar.messageTextField.delegate = self
        messageBar.delegate = self
        view.addSubview(messageBar)
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
    
    func fetchCurrentUserId(){
        guard let userId = Auth.auth().currentUser?.uid else {
            presentError(title: "User Login Error", message: "Please login again as you are not logged in.")
            return
        }
        self.currentUserId = userId
    }
    
    // MARK: - Chat functions
    func startListening(){
        chatManager.listenForChatMessages(user1Id: currentUserId!, user2Id: otherUserProfile.id, limit: 50)
    }

    
    // MARK: - denit functions
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Selector functions
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
    

    // MARK: IBActions
    @IBAction func backButtonTapped(_ sender: Any){
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextFieldDelegate Conformation
extension ChatDetailViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        messageBar.cameraButton.backgroundColor = .blue.withAlphaComponent(1.0)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        messageBar.cameraButton.backgroundColor = .blue.withAlphaComponent(0.5)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.hasText{
            messageBar.cameraButton.isHidden = true
            messageBar.searchButton.isHidden = false
            messageBar.micButton.isHidden = true
            messageBar.pictureButton.isHidden = true
            messageBar.stickerButton.isHidden = true
            messageBar.moreButton.isHidden = true
            messageBar.sendButton.isHidden = false
            
        }
        else{
            messageBar.cameraButton.isHidden = false
            messageBar.searchButton.isHidden = true
            messageBar.micButton.isHidden = false
            messageBar.pictureButton.isHidden = false
            messageBar.stickerButton.isHidden = false
            messageBar.moreButton.isHidden = false
            messageBar.sendButton.isHidden = true
        }
    }
}

extension ChatDetailViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatDetailTableViewCell.identifier, for: indexPath) as! ChatDetailTableViewCell
        cell.configure(message: message, currentUserId: self.currentUserId!, otherUserId: otherUserProfile.id)
        return cell
    }
}

extension ChatDetailViewController: ChatManagerDelegate{
    func didUpdateChatMessages(_ messages: [Message]) {
        self.messages = messages
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func didUpdateUserChats(_ chats: [Chat]) {
        // No need to implement, this was to update all user chats
    }
    
    func chatManagerDidEncounterError(_ error: any Error) {
        
    }
}

extension ChatDetailViewController: MessageBarDelegate{
    func sendTextMessage(content: String) {
        guard let currentUserId = currentUserId else { return }
        Task {
            do {
                try await chatManager.sendMessage(
                    senderId: currentUserId,
                    recipientId: otherUserProfile.id,
                    content: content,
                    type: "text"
                )
                // Message sent successfully. UI will update via the listener.
                print("Text message send initiated.")
            } catch {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
}
