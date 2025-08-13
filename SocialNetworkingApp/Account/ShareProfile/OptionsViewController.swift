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
    private let options:[String]
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        return label
    }()
    
    init(title: String, options: [String]) {
        self.titleLabel.text = title
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleLabel.applyBorders(for: [.bottom], borderWidth: 0.2, borderColor: .lightGray)
    }

    private func createOptionButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        button.backgroundColor = .white
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }
    
    func setupView(){
        view.backgroundColor = .white
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .white
        stackView.translatesAutoresizingMaskIntoConstraints = false
        for optionTitle in options {
            let button = createOptionButton(title: optionTitle)
            button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        view.addSubview(titleLabel)
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 50),
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    @objc private func optionTapped(_ sender: UIButton) {
        //dismiss(animated: true){
            if let selectedOption = sender.titleLabel?.text {
                self.delegate?.optionsViewController(self, didSelectOption: selectedOption)
            }
        //}
    }
}
