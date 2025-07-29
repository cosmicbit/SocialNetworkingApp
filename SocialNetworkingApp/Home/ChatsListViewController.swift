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
    
    private var chatManager = ChatManager()
    private var chats: [Chat] = [] // Stores the list of Chat objects
    var currentUserId: String?
    
    // A dictionary to cache participant usernames, to avoid repeated Firestore lookups
    private var participantUsernameCache: [String: String] = [:]
    
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
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        messagesTableView.register(ChatListCell.self, forCellReuseIdentifier: "ChatListCell") // Register custom cell
        messagesTableView.rowHeight = UITableView.automaticDimension // Allow self-sizing cells
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
    private func prefetchParticipantUsernames() async {
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
        
        // Pre-fetch participant usernames to avoid blocking UI in cellForRowAt
        Task {
            await prefetchParticipantUsernames()
            DispatchQueue.main.async {
                self.messagesTableView.reloadData() // Reload table view on the main thread
                print("UI updated with \(chats.count) user chats.")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListCell
        let chat = chats[indexPath.row]

        // Determine the other participant's ID
        let otherParticipantId = chat.participants.first(where: { $0 != currentUserId }) ?? "Unknown"

        // Get display name from cache or use ID as fallback
        let otherParticipantDisplayName = participantUsernameCache[otherParticipantId] ?? otherParticipantId

        // Get last message content
        let lastMessageContent = chat.lastMessage?.content ?? "No messages yet."

        // Format timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let lastMessageTime = chat.lastMessage?.timestamp.dateValue() ?? chat.updatedAt.dateValue()
        let timeString = dateFormatter.string(from: lastMessageTime)

        cell.configure(with: otherParticipantDisplayName, lastMessage: lastMessageContent, time: timeString)
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

        // Initialize and push the ChatViewController
        let chatDetailVC = ChatDetailViewController()
        //chatDetailVC.otherUserId = otherUserId
        //chatDetailVC.currentUserId = currentUser
        navigationController?.pushViewController(chatDetailVC, animated: true)
    }
}


// MARK: - Custom UITableViewCell for Chat List

class ChatListCell: UITableViewCell {
    let nameLabel = UILabel()
    let lastMessageLabel = UILabel()
    let timeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Labels configuration
        nameLabel.font = UIFont.boldSystemFont(ofSize: 17)
        lastMessageLabel.font = UIFont.systemFont(ofSize: 15)
        lastMessageLabel.textColor = .gray
        timeLabel.font = UIFont.systemFont(ofSize: 13)
        timeLabel.textColor = .lightGray
        timeLabel.textAlignment = .right

        // Add labels to content view
        contentView.addSubview(nameLabel)
        contentView.addSubview(lastMessageLabel)
        contentView.addSubview(timeLabel)

        // Disable autoresizing masks for Auto Layout
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        lastMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        // Set up constraints
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -10), // Push nameLabel away from time

            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            timeLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 80), // Max width for time label

            lastMessageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            lastMessageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            lastMessageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            lastMessageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10) // Pin to bottom
        ])
    }

    func configure(with name: String, lastMessage: String, time: String) {
        nameLabel.text = name
        lastMessageLabel.text = lastMessage
        timeLabel.text = time
    }
}
