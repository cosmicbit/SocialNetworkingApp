//
//  HorizontalScrollingTextView.swift
//  SocialNetworkingApp
//
//  Created by Philips on 05/08/25.
//


import UIKit

// A custom UITextView that enables horizontal scrolling by disabling text wrapping.
// This is useful for displaying long, single-line strings that need to be viewed
// without line breaks.
class HorizontalScrollingTextView: UITextView {
    
    // MARK: - Initializers
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        let textContainer = NSTextContainer(size: .zero)
        super.init(frame: frame, textContainer: textContainer)
        setupTextContainer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextContainer()
    }
    
    private func setupTextContainer() {
        let textContainer = self.textContainer
        textContainer.maximumNumberOfLines = 1
        textContainer.lineFragmentPadding = 0
        textContainer.widthTracksTextView = false
        textContainer.size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        
        self.isScrollEnabled = true
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        
        self.autoresizingMask = [.flexibleWidth]
        self.textContainerInset = .zero
    }
    
    // MARK: - Auto Layout & Content Sizing
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let font = self.font, let text = self.text else {
            return
        }
        let size = (text as NSString).boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: bounds.height),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        self.textContainer.size = CGSize(width: size.width, height: bounds.height)

        contentSize = CGSize(width: size.width, height: bounds.height)
    }
    
    override var text: String! {
        didSet {
            setNeedsLayout()
        }
    }
}
