//
//  EmojiShareView.swift
//  SocialNetworkingApp
//
//  Created by Philips on 06/08/25.
//

import UIKit

class EmojiShareView: UIView {
    
    var currentEmojiUnicode: String = "U+1F642"{
        didSet{
            guard let currentEmojiScalar = emoji(from: currentEmojiUnicode) else {return}
            self.currentEmoji = currentEmojiScalar
        }
    }
    
    var currentEmoji: String = "👍"
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.isScrollEnabled = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(LabelCell.self, forCellWithReuseIdentifier: LabelCell.identifier)
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: ) have not been implemented")
    }

    private func setupView(){
        backgroundColor = .white
        addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 150),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -20),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 20),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100)
        ])
    }
    
    func changeCurrentEmoji(with newEmoji: String){
        currentEmojiUnicode = newEmoji
        collectionView.reloadData()
    }
    
    func emoji(from unicode: String) -> String? {
        let hex = unicode.replacingOccurrences(of: "U+", with: "")
        guard let code = UInt32(hex, radix: 16) else {
            return nil
        }
        guard let scalar = UnicodeScalar(code) else {
            return nil
        }
        return String(scalar)
    }
    
    func setupEmojiLabels(){
        
    }

}


class LabelCell: UICollectionViewCell {
    static let identifier = "LabelCell"

    let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 60)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 8

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
