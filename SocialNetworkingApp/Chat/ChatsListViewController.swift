//
//  MessagesViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 23/07/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ChatsListViewController: UIViewController {
    
    
    @IBOutlet weak var messagesTableView: UITableView!
    
    private var userProfileManager = UserProfileManager()
    private var chatManager = ChatManager()
    private var chats: [Chat] = [] // Stores the list of Chat objects
    var currentUserId: String?
    
    // A dictionary to cache participant usernames, to avoid repeated Firestore lookups
    private var participantUsernameCache: [String: String] = [:]
    private var participantAvatarImageURLCache: [String: URL] = [:]
    private let chatsListTableViewCellHeightRatio = 0.125 * 0.70
    
    private let activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        return view
    }()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChatDetailSegue"{
            print("preparing...")
            let destinationVC = segue.destination as! ChatDetailViewController
            destinationVC.otherUserProfile = sender as? UserProfile
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMessagesTableHeader()
        setupChatsListTableView()
        addRightSwipeToView()
        chatManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let userId = Auth.auth().currentUser?.uid {
            currentUserId = userId
            chatManager.listenForUserChats(userId: userId)
        } else {
            print("User not logged in. Cannot listen for chats.")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        chatManager.detachListeners()
    }
    
    @objc func backToHomeVC(){
        dismiss(animated: true)
    }
    func setupChatsListTableView(){
        messagesTableView.dataSource = self
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        messagesTableView.register(ChatsListTableViewCell.self, forCellReuseIdentifier: "ChatsListTableViewCell") // Register custom cell
        messagesTableView.rowHeight = chatsListTableViewCellHeightRatio * view.frame.height
        messagesTableView.estimatedRowHeight = 80 // Estimate for performance
            
    }
    func setupMessagesTableHeader() {
        let messagesTableHeaderView = ChatsTableHeaderView()
        let headerHeight = messagesTableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        messagesTableHeaderView.frame = CGRect(x: 0, y: 0, width: messagesTableView.bounds.width, height: headerHeight)
        messagesTableView.tableHeaderView = messagesTableHeaderView
    }
    
    func addRightSwipeToView(){
        let swipeToRight = UISwipeGestureRecognizer(target: self, action: #selector(backToHomeVC))
        swipeToRight.direction = .right
        view.addGestureRecognizer(swipeToRight)
    }
    
    // MARK: - Username Fetching (New)
    private func prefetchParticipantUserNames() async {
        guard let currentUserId = self.currentUserId else { return }

        var idsToFetch: Set<String> = []
        for chat in chats {
            for participantId in chat.participants {
                if participantId != currentUserId && participantUsernameCache[participantId] == nil {
                    idsToFetch.insert(participantId)
                }
            }
        }

        if idsToFetch.isEmpty { return }

        // Fetch user data from Firestore for all unknown participants
        // This can be optimized with batched reads if you have many users
        for userId in idsToFetch {
            do {
                let userDoc = try await Firestore.firestore().collection("users").document(userId).getDocument()
                if let username = userDoc.data()?["username"] as? String {
                    participantUsernameCache[userId] = username
                } else {
                    participantUsernameCache[userId] = "User \(userId.prefix(4))..." // Fallback
                }
            } catch {
                print("Error fetching username for \(userId): \(error.localizedDescription)")
                participantUsernameCache[userId] = "Error User" // Indicate an issue
            }
        }
    }
    
    // MARK: - Avatar Fetching (New)
    private func prefetchParticipantAvatars() async {
        guard let currentUserId = self.currentUserId else { return }

        var idsToFetch: Set<String> = []
        for chat in chats {
            for participantId in chat.participants {
                if participantId != currentUserId && participantAvatarImageURLCache[participantId] == nil {
                    idsToFetch.insert(participantId)
                }
            }
        }

        if idsToFetch.isEmpty { return }

        // Fetch user data from Firestore for all unknown participants
        // This can be optimized with batched reads if you have many users
        for userId in idsToFetch {
            do {
                let userDoc = try await Firestore.firestore().collection("users").document(userId).getDocument()
                if let avatarImageURL = userDoc.data()?["avatarImageURL"] as? String {
                    participantAvatarImageURLCache[userId] = URL(string: avatarImageURL)
                } else {
                    participantAvatarImageURLCache[userId] = nil // Fallback
                }
            } catch {
                print("Error fetching avatar for \(userId): \(error.localizedDescription)")
                participantAvatarImageURLCache[userId] = nil // Indicate an issue
            }
        }
    }
    
    // MARK: - Chat functions
    func startChat(with otherUserId: String){
        userProfileManager.getUserProfileByUserID(userId: otherUserId) { result in
            switch result {
            case .success(let userProfile):
                print("fetch profile successful")
                self.performSegue(withIdentifier: "ChatDetailSegue", sender: userProfile)
            case .failure(_):
                print("failed to fetch profile")
            }
        }
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func usernameButtonTapped(_ sender: Any) {
    }
    @IBAction func aiStudioButtonTapped(_ sender: Any) {
    }
    @IBAction func newMessageButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "NewChatSegue", sender: nil)
    }
}

// MARK: - ChatManagerDelegate

extension ChatsListViewController: ChatManagerDelegate{
    func didUpdateUserChats(_ chats: [Chat]) {
        self.chats = chats // Update the data source
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: messagesTableView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: messagesTableView.centerYAnchor)
        ])
        activityIndicatorView.startAnimating()
        // Pre-fetch participant usernames and to avoid blocking UI in cellForRowAt
        Task {
            await prefetchParticipantUserNames()
            await prefetchParticipantAvatars()
            DispatchQueue.main.async {
                self.messagesTableView.reloadData() // Reload table view on the main thread
                print("UI updated with \(chats.count) user chats.")
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.removeFromSuperview()
            }
        }
    }

    func didUpdateChatMessages(_ messages: [Message]) {
        // This method is primarily for ChatViewController, not ChatListViewController
        // No action needed here, but it's part of the protocol
    }

    func chatManagerDidEncounterError(_ error: Error) {
        // Display an error alert to the user
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ChatsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatsListTableViewCell", for: indexPath) as! ChatsListTableViewCell
        let chat = chats[indexPath.row]

        // Determine the other participant's ID
        let otherParticipantId = chat.participants.first(where: { $0 != currentUserId }) ?? "Unknown"

        // Get display name from cache or use ID as fallback
        let otherParticipantDisplayName = participantUsernameCache[otherParticipantId] ?? otherParticipantId
        let otherParticipantAvatarImageURL = participantAvatarImageURLCache[otherParticipantId] ?? nil

        // Format timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let lastMessageTime = chat.lastMessage?.timestamp.dateValue() ?? chat.updatedAt.dateValue()
        let timeString = dateFormatter.string(from: lastMessageTime)

        cell.configure(with: otherParticipantDisplayName, imageURL: otherParticipantAvatarImageURL, time: timeString)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect row after tap

        let selectedChat = chats[indexPath.row]

        guard let currentUser = currentUserId,
              let otherUserId = selectedChat.participants.first(where: { $0 != currentUser }) else {
            print("Could not determine chat participants for navigation.")
            // Show alert or handle error
            return
        }
        startChat(with: otherUserId)
    }
}



