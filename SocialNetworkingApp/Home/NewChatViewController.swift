//
//  NewChatViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 25/07/25.
//


import UIKit
import FirebaseAuth
import FirebaseFirestore

class NewChatViewController: UIViewController {
    
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var newMessageTableView: UITableView!

    private var users: [AppUser] = [] // Assuming you have an AppUser struct for displaying users
    private var filteredUsers: [AppUser] = []
    private let searchController = UISearchController(searchResultsController: nil)

    private var currentUserId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        currentUserId = Auth.auth().currentUser?.uid
        if currentUserId == nil {
            print("Error: Current user ID is nil. Cannot start new chat.")
            // Handle this gracefully, e.g., redirect to login
            let alert = UIAlertController(title: "Error", message: "You must be logged in to start a new chat.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
            return
        }

        //setupSearchController()
        setupTableView()
        setupTableHeader()
        fetchUsers() // Fetch all users to display
    }

    // MARK: - UI Setup


    private func setupTableView() {
        newMessageTableView.delegate = self
        newMessageTableView.dataSource = self
        newMessageTableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell") // Simple cell for now
        view.addSubview(newMessageTableView)
    }
    
    func setupTableHeader() {
        let newMessageTableHeaderView = NewMessageTableHeaderView()
        let headerHeight = newMessageTableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        newMessageTableHeaderView.frame = CGRect(x: 0, y: 0, width: newMessageTableView.bounds.width, height: headerHeight)
        newMessageTableView.tableHeaderView = newMessageTableHeaderView
    }

    // MARK: - Data Fetching

    private func fetchUsers() {
        // Fetch all users from your "users" collection
        // Exclude the current logged-in user
        Firestore.firestore().collection("users").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                let alert = UIAlertController(title: "Error", message: "Failed to load users: \(error.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }

            self.users = querySnapshot?.documents.compactMap { doc -> AppUser? in
                // Assuming your user documents have a "username" field and their ID is the document ID
                let data = doc.data()
                let userId = doc.documentID
                if userId == self.currentUserId { return nil } // Exclude current user

                if let username = data["username"] as? String {
                    return AppUser(id: userId, username: username)
                }
                return nil
            } ?? []

            // Sort users alphabetically by username
            self.users.sort { $0.username.lowercased() < $1.username.lowercased() }

            self.filteredUsers = self.users // Initially show all users
            self.newMessageTableView.reloadData()
        }
    }

    // MARK: - Navigation

    private func startChat(with selectedUser: AppUser) {
        guard let currentUserId = self.currentUserId else {
            print("Current user ID is missing.")
            return
        }
        //performSegue(withIdentifier: "ChatDetailSegue", sender: nil)
        // Initialize and push the ChatViewController
        let chatSB = UIStoryboard(name: "Chat", bundle: nil)
        let chatVC = chatSB.instantiateViewController(withIdentifier: "ChatDetailViewController")
        //chatVC.currentUserId = currentUserId
        //chatVC.otherUserId = selectedUser.id // Pass the selected user's ID
        

        navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension NewChatViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text?.lowercased() ?? ""

        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter { $0.username.lowercased().contains(searchText) }
        }
        newMessageTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension NewChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let user = filteredUsers[indexPath.row]
        cell.textLabel?.text = user.username
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = filteredUsers[indexPath.row]
        startChat(with: selectedUser)
    }
}

// MARK: - AppUser Struct (Example)
// Make sure you have a similar struct or class representing your user data
struct AppUser: Identifiable, Hashable {
    let id: String
    let username: String
    // Add other user properties like profile picture URL, etc.
}
