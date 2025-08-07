//
//  EmojiPickerViewController.swift
//  SocialNetworkingApp
//
//  Created by Philips on 07/08/25.
//

import UIKit

protocol PickerDelegate: AnyObject {
    func didSelect(this: Any)
}

class EmojiPickerViewController: UIViewController {

    private var emojis: [String] = []
    private let emojiFileName = "emoji"
    private let emojiFileType = "txt"
    weak var delegate: PickerDelegate?
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search"
        searchBar.searchTextField.font = UIFont.systemFont(ofSize: 13)
        searchBar.searchTextField.textColor = .label
        searchBar.setSearchFieldBackgroundImage(UIImage(), for: .normal)
        searchBar.backgroundImage = UIImage()
        searchBar.searchBarStyle = .prominent
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let numberOfItemsInRow: CGFloat = 6
        let interItemSpacing: CGFloat = 8
        let sectionInset: CGFloat = 8
        let totalSpacing = (interItemSpacing * (numberOfItemsInRow - 1)) + (sectionInset * 2)
        let itemSize = (view.bounds.width - totalSpacing) / numberOfItemsInRow
        layout.itemSize = CGSize(width: itemSize, height: itemSize)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsVerticalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getEmojisFromFile()
        
        let blurEffect = UIBlurEffect(style: .prominent) // Example: a subtle blur
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurredEffectView, at: 0)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            blurredEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurredEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurredEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurredEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func getEmojisFromFile(){
        guard let filePath = Bundle.main.path(forResource: emojiFileName, ofType: emojiFileType) else{
            print("File not found in the main bundle.")
            return
        }
        do {
            let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
            emojis = fileContents.components(separatedBy: "\n")
        } catch {
            print("Error reading the file: \(error)")
        }
        
    }

}

extension EmojiPickerViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as? EmojiCell else {
            return UICollectionViewCell()
        }
        let emoji = emojis[indexPath.row]
        cell.configure(withEmoji: emoji)
        return cell
    }
    
}

extension EmojiPickerViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedEmoji = emojis[indexPath.item]
        delegate?.didSelect(this: selectedEmoji)
        dismiss(animated: true, completion: nil)
    }
}


// A simple custom UICollectionViewCell to hold the emoji
class EmojiCell: UICollectionViewCell {
    
    static let identifier = "EmojiCell"
    
    let emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func configure(withEmoji unicode: String){
        let hex = unicode.replacingOccurrences(of: "U+", with: "")
        
        guard let code = UInt32(hex, radix: 16) else {
            return
        }
        guard let scalar = UnicodeScalar(code) else {
            return
        }
        emojiLabel.text = String(scalar)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
