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
    
    var messageBubbleLeadingConstraint: NSLayoutConstraint!
    var messageBubbleTrailingConstraint: NSLayoutConstraint!
    var messageLabelLeadingConstraint: NSLayoutConstraint!
    var messageLabelTrailingConstraint: NSLayoutConstraint!
    
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
        label.textAlignment = .left
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
        messageBubbleView.layer.cornerRadius = 36 / 2 //messageBubbleView.frame.height / 4
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.messageBubbleLeadingConstraint.isActive = false
        self.messageBubbleTrailingConstraint.isActive = false
        self.messageLabelLeadingConstraint.isActive = false
        self.messageLabelTrailingConstraint.isActive = false
        self.message = nil
        self.messageLabel.text = nil // Reset message label text
        self.messageBubbleView.backgroundColor = .systemBlue.withAlphaComponent(0.75)
        messageLabel.textAlignment = .left
    }
    
    func configure(message: Message, currentUserId: String, otherUserId: String){
        self.message = message
        self.messageLabel.text = message.content.trimmingCharacters(in: .whitespacesAndNewlines)
        self.messageLabel.backgroundColor = .clear
        self.currentUserId = currentUserId
        self.otherUserid = otherUserId
        messageBubbleLeadingConstraint.isActive = false
        messageBubbleTrailingConstraint.isActive = false
        if let text = self.messageLabel.text {
            let isShortMessage = (text.count <= 2)
            messageLabel.textAlignment = isShortMessage ? .center : .left
        }
        if message.senderId == currentUserId{
            messageBubbleTrailingConstraint.isActive = true
        }
        else{
            messageBubbleLeadingConstraint.isActive = true
        }
        
        messageLabelLeadingConstraint.isActive = true
        messageLabelTrailingConstraint.isActive = true
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
            messageLabel.bottomAnchor.constraint(equalTo: messageBubbleView.bottomAnchor, constant: -8),
            //messageLabel.leadingAnchor.constraint(lessThanOrEqualTo: messageBubbleView.centerXAnchor, constant: -messageLabel.frame.width / 2)
        ])
        
        messageLabelLeadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: messageBubbleView.leadingAnchor, constant: 10)
        messageLabelTrailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: messageBubbleView.trailingAnchor, constant: -10)

        NSLayoutConstraint.activate([
            messageBubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            messageBubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])

        messageBubbleLeadingConstraint = messageBubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10)
        messageBubbleTrailingConstraint = messageBubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)

        messageBubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75).isActive = true
        messageBubbleView.widthAnchor.constraint(greaterThanOrEqualTo: messageBubbleView.heightAnchor).isActive = true
    }
}
