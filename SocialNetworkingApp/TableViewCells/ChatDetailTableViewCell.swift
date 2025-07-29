//
//  ChatDetailTableViewCell.swift
//  SocialNetworkingApp
//
//  Created by Philips on 29/07/25.
//

import UIKit

class ChatDetailTableViewCell: UITableViewCell {
    
    static let identifier = "ChatDetailTableViewCell"
    
    private var message: Message!
    private var currentUserId: String!
    private var otherUserid: String!
    
    var leadingConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!
    
    let messageBubbleView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.backgroundColor = .systemBlue.withAlphaComponent(0.75)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .center
        return view
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder) has been called.")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        messageBubbleView.layer.cornerRadius = messageBubbleView.frame.height / 2
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.leadingConstraint = messageBubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10)
        self.trailingConstraint = messageBubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        self.message = nil
        
    }
    
    func configure(message: Message, currentUserId: String, otherUserId: String){
        self.message = message
        self.messageLabel.text = message.content
        self.currentUserId = currentUserId
        self.otherUserid = otherUserId
        
        if message.senderId == currentUserId{
            leadingConstraint.isActive = false
            trailingConstraint.isActive = true
        }
        else{
            leadingConstraint.isActive = true
            trailingConstraint.isActive = false
        }
        
        DispatchQueue.main.async {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    func setupView(){
        selectionStyle = .none
        contentView.addSubview(messageBubbleView)
        messageBubbleView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: messageBubbleView.topAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: messageBubbleView.leadingAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(greaterThanOrEqualTo: messageBubbleView.trailingAnchor, constant: -10),
            messageLabel.centerXAnchor.constraint(equalTo: messageBubbleView.centerXAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: messageBubbleView.bottomAnchor, constant: -8)
        ])
        
        NSLayoutConstraint.activate([
            messageBubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            messageBubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
        
        leadingConstraint = messageBubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10)
        trailingConstraint = messageBubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        
        messageBubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75).isActive = true
        messageBubbleView.widthAnchor.constraint(greaterThanOrEqualTo: messageBubbleView.heightAnchor).isActive = true
        
        
        
    }
    
}
