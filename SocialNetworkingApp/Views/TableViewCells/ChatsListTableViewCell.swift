//
//  ChatsListTableViewCell.swift
//  SocialNetworkingApp
//
//  Created by Philips on 30/07/25.
//

import UIKit

// MARK: - Custom UITableViewCell for Chat List

class ChatsListTableViewCell: UITableViewCell {
    let nameLabel = UILabel()
    let timeLabel = UILabel()
    let avatarImageView = AvatarCircleView()
    
    let cameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.tintColor = .darkGray
        button.backgroundColor = .clear
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // Labels configuration
        nameLabel.font = UIFont.systemFont(ofSize: 13)
        timeLabel.font = UIFont.systemFont(ofSize: 13)
        timeLabel.textColor = .gray

        // Add labels to content view
        contentView.addSubview(nameLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(cameraButton)

        // Disable autoresizing masks for Auto Layout
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.translatesAutoresizingMaskIntoConstraints = false

        // Set up constraints
        NSLayoutConstraint.activate([
            
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            avatarImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor),
            
            nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor, constant: -8),
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: cameraButton.leadingAnchor, constant: -10), // Push nameLabel away from time

            timeLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 15),
            timeLabel.trailingAnchor.constraint(equalTo: cameraButton.leadingAnchor, constant: -10), // Max width for time label
            
            cameraButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            cameraButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            cameraButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            cameraButton.widthAnchor.constraint(equalTo: cameraButton.heightAnchor)

        ])
    }

    func configure(with name: String, imageURL: URL?, time: String) {
        nameLabel.text = name
        timeLabel.text = time
        avatarImageView.configure(imageURL: imageURL)
    }
}
