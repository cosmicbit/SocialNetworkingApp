//
//  ColorShareView.swift
//  SocialNetworkingApp
//
//  Created by Philips on 06/08/25.
//

import UIKit

class ColorShareView: UIView {
    
    var currentColor: AvailableColors = .blue {
        didSet{
            self.backgroundColor = currentColor.uiColor
        }
    }
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
    
    enum AvailableColors: Int, CaseIterable{
        case blue = 0, green, black, orange, systemPink
        var uiColor: UIColor {
            switch self {
            case .blue:
                return .blue
            case .green:
                return .green
            case .black:
                return .black
            case .orange:
                return .orange
            case .systemPink:
                return .systemPink
            }
        }
        mutating func toNextColor(){
            self = self.nextColor
        }
        
        var nextColor: AvailableColors{
            guard let color = AvailableColors(rawValue: (self.rawValue + 1) % AvailableColors.allCases.count) else { return .blue}
            return color
        }
    }
}
