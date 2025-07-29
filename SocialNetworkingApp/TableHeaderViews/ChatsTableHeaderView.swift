//
//  ChatsTableHeaderView.swift
//  SocialNetworkingApp
//
//  Created by Philips on 23/07/25.
//

import UIKit

class ChatsTableHeaderView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var metaButton: UIButton!
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var notesCollectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit(){
        
        let nib = UINib(nibName: "ChatsTableHeaderView", bundle: nil)
        nib.instantiate(withOwner: self)
        contentView.frame = bounds
        addSubview(contentView)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        searchContainerView.layer.cornerRadius = searchContainerView.frame.height / 2
    }
    @IBAction func metaButtonTapped(_ sender: Any) {
    }
    @IBAction func requestsButtonTapped(_ sender: Any) {
    }
}
