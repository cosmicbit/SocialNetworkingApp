//
//  OptionsViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 11/08/25.
//


import UIKit

protocol OptionsViewControllerDelegate: AnyObject {
    func optionsViewController(_ controller: OptionsViewController, didSelectOption option: String)
}

class OptionsViewController: UIViewController {
    
    weak var delegate: OptionsViewControllerDelegate?
    private let titleLabel: String
    private let options:[String]
    
    init(title: String, options: [String]) {
        self.titleLabel = title
        self.options = options
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // Helper function to create a styled button
    private func createOptionButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        button.backgroundColor = .white
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }
    
    func setupView(){
        view.backgroundColor = .white
        // Add your options UI here
        let titleLabel = UILabel()
        titleLabel.text = self.titleLabel
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // 3. Dynamically create buttons based on the options array
        for optionTitle in options {
            let button = createOptionButton(title: optionTitle)
            button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        // Add the title label and the stack view to the main view
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        
        
        NSLayoutConstraint.activate([
            // Pin the title label to the top, with some padding
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Pin the stack view below the title label
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    // 4. A single action method to handle all button taps
    @objc private func optionTapped(_ sender: UIButton) {
        // Get the title from the tapped button
        if let selectedOption = sender.titleLabel?.text {
            // 5. Tell the delegate that an option was selected
            delegate?.optionsViewController(self, didSelectOption: selectedOption)
        }
        dismiss(animated: true, completion: nil)
    }
}
