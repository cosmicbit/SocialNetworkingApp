//
//  EmojiShareView.swift
//  SocialNetworkingApp
//
//  Created by Philips on 06/08/25.
//

import UIKit

class EmojiShareView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder: ) have not been implemented")
    }

    private func setupView(){
        backgroundColor = .green
    }
    
    func emoji(from unicode: String) -> String? {
        // We remove the "U+" prefix and convert the rest to a hexadecimal number
        let hex = unicode.replacingOccurrences(of: "U+", with: "")
        
        guard let code = UInt32(hex, radix: 16) else {
            return nil
        }
        guard let scalar = UnicodeScalar(code) else {
            return nil
        }
        return String(scalar)
    }

}
