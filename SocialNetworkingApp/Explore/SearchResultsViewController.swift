//
//  SearchResultsViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 17/07/25.
//

import UIKit

protocol SearchResultsChildVC: AnyObject {
    var searchQuery: String? { get set } // To receive the search query
    func refreshResults() // To trigger a data refresh
}

class SearchResultsViewController: UIViewController {

    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var resultsTypeSegementedControl: PrimarySegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    var initialSearchQuery: String = ""
    var searchQuery: String = ""
    
    private var contentViewControllers: [UIViewController & SearchResultsChildVC] = []
    private var currentContentViewController: (UIViewController & SearchResultsChildVC)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViewControllers()
        setupCustomSegmentedControl()
        searchTextField.text = initialSearchQuery
    }
    
    func setupCustomSegmentedControl() {
        resultsTypeSegementedControl.segments = ["For You", "Accounts", "Reels", "Audio", "Tags", "Places"]
        resultsTypeSegementedControl.delegate = self
        resultsTypeSegementedControl.selectedSegmentColor = .clear
        resultsTypeSegementedControl.normalSegmentColor = .clear
        resultsTypeSegementedControl.selectedTextColor = .label // Adapts to light/dark mode
        resultsTypeSegementedControl.normalTextColor = .secondaryLabel
        resultsTypeSegementedControl.indicatorColor = .label
        resultsTypeSegementedControl.indicatorHeight = 2.0
        resultsTypeSegementedControl.segmentFont = .systemFont(ofSize: 11, weight: .regular)
        resultsTypeSegementedControl.selectedSegmentFont = .systemFont(ofSize: 11, weight: .regular)
        resultsTypeSegementedControl.translatesAutoresizingMaskIntoConstraints = false
        resultsTypeSegementedControl.selectedSegmentIndex = 0
    }
    
    // MARK: - Child View Controller Setup & Display
    private func setupChildViewControllers() {
        // Instantiate each child view controller and add it to the array
        // Make sure to pass the initial query.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let forYouVC = storyboard.instantiateViewController(withIdentifier: "ForYouResultsViewController") as! ForYouResultsViewController
        forYouVC.searchQuery = initialSearchQuery
        contentViewControllers.append(forYouVC)

        let accountsVC = storyboard.instantiateViewController(withIdentifier: "AccountsResultsViewController") as! AccountsResultsViewController
        accountsVC.searchQuery = initialSearchQuery
        contentViewControllers.append(accountsVC)

//        let reelsVC = ReelsResultsViewController()
//        reelsVC.searchQuery = initialSearchQuery
//        childViewControllers.append(reelsVC)
//
//        let audioVC = AudioResultsViewController()
//        audioVC.searchQuery = initialSearchQuery
//        childViewControllers.append(audioVC)
//
//        let tagsVC = TagsResultsViewController()
//        tagsVC.searchQuery = initialSearchQuery
//        childViewControllers.append(tagsVC)
//
//        let placesVC = PlacesResultsViewController()
//        placesVC.searchQuery = initialSearchQuery
//        childViewControllers.append(placesVC)
    }
    
    private func displayChildViewController(at index: Int) {
        guard index >= 0, index < contentViewControllers.count else {
            print("Error: Invalid segment index \(index)")
            return
        }

        let newViewController = contentViewControllers[index]

        // If the new view controller is already the current one, do nothing
        if newViewController === currentContentViewController {
            return
        }

        // 1. Remove the old child view controller (if any)
        if let currentVC = currentContentViewController {
            currentVC.willMove(toParent: nil)
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }

        // 2. Add the new child view controller
        addChild(newViewController)
        containerView.addSubview(newViewController.view)

        // 3. Set up constraints for the new child's view to fill the container
        newViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            newViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            newViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            newViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])

        newViewController.didMove(toParent: self)

        currentContentViewController = newViewController
        currentContentViewController?.refreshResults() // Trigger content refresh for the new tab
    }
   
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchView.layer.cornerRadius = searchView.bounds.height / 2
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    @IBAction func searchCancelButtonTapped(_ sender: Any) {
        searchTextField.text?.removeAll()
    }
    @IBAction func searchButtonTapped(_ sender: Any) {
    }
    

}

extension SearchResultsViewController: PrimarySegmentedControlDelegate{
    func segmentedControl(_ segmentedControl: PrimarySegmentedControl, didSelectSegmentAt index: Int) {
        displayChildViewController(at: index)
    }
    
    
}



