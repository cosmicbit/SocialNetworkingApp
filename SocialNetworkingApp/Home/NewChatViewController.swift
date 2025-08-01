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

    private var users: [UserProfile] = [] // Assuming you have an AppUser struct for displaying users
    private var filteredUsers: [UserProfile] = []
    private var currentUserId: String?
    
    private var userProfileManager = UserProfileManager()

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChatDetailSegue"{
            let destinationVC = segue.destination as! ChatDetailViewController
            destinationVC.otherUserProfile = sender as? UserProfile
        }
    }
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

        
        setupTableView()
        setupTableHeader()
        fetchUsers() // Fetch all users to display
    }

    // MARK: - UI Setup


    private func setupTableView() {
        newMessageTableView.delegate = self
        newMessageTableView.dataSource = self
        let nib = UINib(nibName: NewChatTableViewCell.identifier, bundle: nil)
        newMessageTableView.register(nib, forCellReuseIdentifier: NewChatTableViewCell.identifier) // Simple cell for now
        newMessageTableView.rowHeight = 60
        view.addSubview(newMessageTableView)
    }
    
    func setupTableHeader() {
        let newMessageTableHeaderView = NewChatTableHeaderView()
        let headerHeight = newMessageTableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        newMessageTableHeaderView.frame = CGRect(x: 0, y: 0, width: newMessageTableView.bounds.width, height: headerHeight)
        newMessageTableView.tableHeaderView = newMessageTableHeaderView
    }

    // MARK: - Data Fetching

    private func fetchUsers() {
        userProfileManager.getAllUsers { result in
            switch result {
            case .success(let users):
                self.users = users
                self.users.sort { $0.name.lowercased() < $1.name.lowercased() }
                self.filteredUsers = self.users
                self.newMessageTableView.reloadData()
            case .failure(let error):
                self.presentError(title: "Error fetching Profiles", message: error.localizedDescription)
            }
        }
    }

    // MARK: - Navigation

    private func startChat(with selectedUser: UserProfile) {
        performSegue(withIdentifier: "ChatDetailSegue", sender: selectedUser)
    }
    
    
    
    @IBAction func backButtonTapped(_ sender: Any){
        navigationController?.popViewController(animated: true)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: NewChatTableViewCell.identifier, for: indexPath) as! NewChatTableViewCell
        let user = filteredUsers[indexPath.row]
        cell.configure(userProfile: user)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedUser = filteredUsers[indexPath.row]
        startChat(with: selectedUser)
    }
}

extension NewChatViewController: SearchResultProfileTableViewCellDelegate{
    
}
