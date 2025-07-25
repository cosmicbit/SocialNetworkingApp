//
//  MessageManager.swift
//  SocialNetworkingApp
//
//  Created by Philips on 25/07/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth // Assuming you have Firebase Auth for current user ID

// MARK: - ChatManagerDelegate Protocol

protocol ChatManagerDelegate: AnyObject {
    func didUpdateChatMessages(_ messages: [Message])
    func didUpdateUserChats(_ chats: [Chat])
    func chatManagerDidEncounterError(_ error: Error)
}

class ChatManager {
    private let db = Firestore.firestore()
    private var messagesListener: ListenerRegistration?
    private var chatsListener: ListenerRegistration?

    weak var delegate: ChatManagerDelegate?

    // MARK: - Helper: Generate Chat ID

    private func getChatID(for user1Id: String, and user2Id: String) -> String {
        let sortedUserIds = [user1Id, user2Id].sorted()
        return sortedUserIds.joined(separator: "_")
    }

    // MARK: - Get (Retrieve) Data

    /// Fetches a list of chats for the current user in real-time.
    /// - Parameter userId: The ID of the current logged-in user.
    func listenForUserChats(userId: String) {
        // Detach existing listener if any
        chatsListener?.remove()

        // Query chats where 'participants' array contains the userId
        // Order by 'updatedAt' descending to show most recent chats first
        chatsListener = db.collection("chats")
            .whereField("participants", arrayContains: userId)
            .order(by: "updatedAt", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error listening for user chats: \(error.localizedDescription)")
                    self.delegate?.chatManagerDidEncounterError(error)
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    print("No chat documents found.")
                    self.delegate?.didUpdateUserChats([]) // Notify with empty array
                    return
                }

                // Map Firestore documents to Chat structs
                let userChats = documents.compactMap { doc -> Chat? in
                    try? doc.data(as: Chat.self)
                }
                print("Successfully fetched \(userChats.count) user chats.")
                self.delegate?.didUpdateUserChats(userChats) // Notify delegate
            }
    }

    /// Fetches messages for a specific chat in real-time.
    /// - Parameters:
    ///   - user1Id: The ID of the current user.
    ///   - user2Id: The ID of the other user in the chat.
    ///   - limit: Optional. The maximum number of messages to fetch initially (for pagination).
    func listenForChatMessages(user1Id: String, user2Id: String, limit: Int = 50) {
        // Detach existing listener if any
        messagesListener?.remove()

        let chatId = getChatID(for: user1Id, and: user2Id)
        let messagesCollectionRef = db.collection("chats").document(chatId).collection("messages")

        messagesListener = messagesCollectionRef
            .order(by: "timestamp", descending: false) // Order by timestamp ascending for chat history
            .limit(to: limit) // Limit initial load
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error listening for messages: \(error.localizedDescription)")
                    self.delegate?.chatManagerDidEncounterError(error)
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    print("No messages found in chat: \(chatId)")
                    self.delegate?.didUpdateChatMessages([]) // Notify with empty array
                    return
                }

                // Map Firestore documents to Message structs
                let currentChatMessages = documents.compactMap { doc -> Message? in
                    try? doc.data(as: Message.self)
                }
                print("Successfully fetched \(currentChatMessages.count) messages for chat: \(chatId)")
                self.delegate?.didUpdateChatMessages(currentChatMessages) // Notify delegate
            }
    }

    /// Fetches older messages for pagination.
    /// - Parameters:
    ///   - user1Id: The ID of the current user.
    ///   - user2Id: The ID of the other user in the chat.
    ///   - lastMessageTimestamp: The timestamp of the oldest message currently loaded.
    ///   - limit: The number of additional messages to fetch.
    func fetchMoreChatMessages(user1Id: String, user2Id: String, lastMessageTimestamp: Timestamp, limit: Int = 20, completion: @escaping ([Message]?, Error?) -> Void) {
        let chatId = getChatID(for: user1Id, and: user2Id)
        let messagesCollectionRef = db.collection("chats").document(chatId).collection("messages")

        messagesCollectionRef
            .order(by: "timestamp", descending: false)
            .end(before: [lastMessageTimestamp]) // Fetch messages older than this timestamp
            .limit(to: limit)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching more messages: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    completion([], nil) // No new documents, but no error
                    return
                }

                let newMessages = documents.compactMap { doc -> Message? in
                    try? doc.data(as: Message.self)
                }
                print("Fetched \(newMessages.count) older messages for chat: \(chatId)")
                completion(newMessages, nil)
            }
    }


    /// Fetches a single chat document by its ID (useful if you need to check existence or details)
    /// - Parameter chatId: The combined sorted user IDs.
    /// - Returns: A `Chat` object or `nil` if not found.
    func getChat(chatId: String) async throws -> Chat? {
        let chatDocRef = db.collection("chats").document(chatId)
        let document = try await chatDocRef.getDocument()
        return try document.data(as: Chat.self)
    }


    // MARK: - Post (Send) Data

    /// Sends a new message to a chat.
    /// This function also ensures the chat document exists or creates it,
    /// and relies on a Cloud Function to update `lastMessage` and `updatedAt` on the parent chat.
    /// - Parameters:
    ///   - senderId: The ID of the user sending the message.
    ///   - recipientId: The ID of the recipient user.
    ///   - content: The message content.
    ///   - type: The type of message (e.g., "text", "image").
    ///   - imageUrl: Optional URL for image messages.
    ///   - fileUrl: Optional URL for file messages.
    ///   - fileName: Optional file name for file messages.
    func sendMessage(senderId: String, recipientId: String, content: String, type: String = "text", imageUrl: URL? = nil, fileUrl: URL? = nil, fileName: String? = nil) async throws {

        let chatId = getChatID(for: senderId, and: recipientId)
        let chatDocRef = db.collection("chats").document(chatId)
        let messagesCollectionRef = chatDocRef.collection("messages")

        let newMessage = Message(
            senderId: senderId,
            content: content,
            type: type,
            imageUrl: imageUrl,
            fileUrl: fileUrl,
            fileName: fileName
        )

        do {
            // 1. Ensure the chat document exists.
            // This is an 'upsert' pattern: if it exists, it does nothing
            // if it doesn't, it creates it.
            let chatExists = try await chatDocRef.getDocument().exists
            if !chatExists {
                let initialChat = Chat(participants: [senderId, recipientId])
                // We are explicitly setting the document ID
                try chatDocRef.setData(from: initialChat)
                print("Created new chat document: \(chatId)")
            }

            // 2. Add the new message to the messages subcollection.
            _ = try messagesCollectionRef.addDocument(from: newMessage)
            print("Message sent successfully to chat: \(chatId)")

        } catch {
            print("Error sending message or creating/updating chat: \(error.localizedDescription)")
            throw error // Re-throw the error for UI handling
        }
    }

    /// Marks a message as read by a specific user.
    /// - Parameters:
    ///   - chatId: The ID of the chat.
    ///   - messageId: The ID of the message to mark as read.
    ///   - userId: The ID of the user who read the message.
    func markMessageAsRead(chatId: String, messageId: String, userId: String) async throws {
        let messageRef = db.collection("chats").document(chatId).collection("messages").document(messageId)

        do {
            try await messageRef.updateData([
                "readBy": FieldValue.arrayUnion([userId]) // Add userId to the 'readBy' array
            ])
            print("Message \(messageId) in chat \(chatId) marked as read by \(userId)")
        } catch {
            print("Error marking message as read: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Cleanup

    /// Detaches all Firestore listeners. Call this when the user logs out or the app shuts down.
    func detachListeners() {
        messagesListener?.remove()
        messagesListener = nil
        chatsListener?.remove()
        chatsListener = nil
        print("Firestore listeners detached.")
    }
}
