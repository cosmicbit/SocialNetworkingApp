//
//  CreateAlertActionSheetView.swift
//  SocialNetworkingApp
//
//  Created by Philips on 14/07/25.
//

import UIKit

class CreateAlertActionSheetView: UIView {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var dragView: UIView!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        initSubViews()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initSubViews()
    }
    func initSubViews() {
        let nib = UINib(nibName: "CreateAlertActionSheetView", bundle: nil)
        nib.instantiate(withOwner: self)
        contentView.frame = bounds
        
        addSubview(contentView)
    }
    
    override func layoutSubviews() {
        contentView.layer.cornerRadius = 25
        dragView.layer.cornerRadius = 1
        dragView.layer.backgroundColor = UIColor.darkGray.cgColor
    }
}
