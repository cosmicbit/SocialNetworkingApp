//
//  SearchViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 16/07/25.
//

import UIKit
import FirebaseFirestore

class SearchViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchCancelButton: UIButton!

    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    private var userProfiles: [UserProfile] = [] {
        didSet{
            searchResultsTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchResultsSegue" {
            let destinationVC = segue.destination as! SearchResultsViewController
            destinationVC.initialSearchQuery = sender as! String
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchView.layer.cornerRadius = searchView.bounds.height / 2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField.becomeFirstResponder()
    }
    
    func setupViews(){
        navigationItem.leftBarButtonItem = nil
        searchTextField.backgroundColor = .systemGray6
        searchTextField.delegate = self
        searchCancelButton.isHidden = true
        searchButton.isHidden = true
        searchButton.transform = CGAffineTransform(scaleX: 0, y: 0)
        addBackgroundTap()
        
        searchResultsTableView.dataSource = self
        searchResultsTableView.estimatedRowHeight = 80
        searchResultsTableView.rowHeight = UITableView.automaticDimension
        searchResultsTableView.tableFooterView = UIView()
        searchResultsTableView.separatorStyle = .none
        
    }
    
    func addBackgroundTap(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func fetchProfileResults(keyword: String){
        let upm = UserProfileManager()
        upm.getUserProfilesByUsernameOrName(username: keyword, name: keyword) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let userProfiles):
                DispatchQueue.main.async {
                    self.userProfiles = userProfiles
                }
                
            case .failure(let error):
                print("Error updating like count in UI: \(error.localizedDescription)")
            }
            
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
   
    
    @IBAction func searchCancelButtonTapped(_ sender: Any) {
        searchTextField.text?.removeAll()
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        let searchQuery = searchTextField.text
        performSegue(withIdentifier: "SearchResultsSegue", sender: searchQuery)
    }
}

extension SearchViewController: UITextFieldDelegate{
    
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.hasText{
            searchCancelButton.isHidden = false
            searchButton.isHidden = false
            searchButton.transform = CGAffineTransform.identity
            fetchProfileResults(keyword: textField.text!)
            
        }
        else{
            searchCancelButton.isHidden = true
            searchButton.isHidden = true
            searchButton.transform = CGAffineTransform(scaleX: 0, y: 0)
            userProfiles.removeAll()
        }
    }
    
    
}

extension SearchViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userProfiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userProfile = userProfiles[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultProfileTableViewCell.identifier, for: indexPath) as! SearchResultProfileTableViewCell
        cell.configure(userProfile: userProfile, delegate: self)
        return cell
    }
    
    
}

extension SearchViewController: UITableViewDelegate{
    
}

extension SearchViewController: SearchResultProfileTableViewCellDelegate{
    
}
