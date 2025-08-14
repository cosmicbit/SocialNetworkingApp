//
//  GradientPreset.swift
//  SocialNetworkingApp
//
//  Created by Philips on 12/08/25.
//


import UIKit

// Define a protocol to ensure each gradient preset provides the necessary properties.
protocol GradientRepresentable {
    var uiColors: [UIColor] { get }
    var cgColors: [CGColor] { get }
    var locations: [NSNumber]? { get }
    var startPoint: CGPoint { get }
    var endPoint: CGPoint { get }
}

enum GradientPreset: Int, CaseIterable, GradientRepresentable{
    case greenToBlue
    case darkGray
    case yellowToPink
    case pinkToPurple
    case blueToPurple
    
    var uiColors: [UIColor] {
        switch self {
        case .greenToBlue:
            return [
                UIColor(named: "GreenToBlue1") ?? UIColor.green,
                UIColor(named: "GreenToBlue2") ?? UIColor.blue
            ]
        case .darkGray:
            return [
                UIColor(named: "darkGray") ?? UIColor.darkGray
            ]
        case .yellowToPink:
            return [
                UIColor(named: "YellowToPink1") ?? UIColor.yellow,
                UIColor(named: "YellowToPink2") ?? UIColor.systemPink
            ]
        case .pinkToPurple:
            return [
                UIColor(named: "PinkToPurple1") ?? UIColor.systemPink,
                UIColor(named: "PinkToPurple2") ?? UIColor.systemPurple
            ]
        case .blueToPurple:
            return [
                UIColor(named: "BlueToPurple1") ?? UIColor.blue,
                UIColor(named: "BlueToPurple2") ?? UIColor.systemPurple
            ]
        }
    }
    
    var cgColors: [CGColor] {
        return self.uiColors.compactMap { $0.cgColor }
    }
    
    var locations: [NSNumber]? {
        switch self {
        case .greenToBlue, .yellowToPink, .pinkToPurple, .blueToPurple:
            [0.0, 1.0]
        case .darkGray:
            nil
        }
    }
    
    var startPoint: CGPoint {
        return CGPoint(x: 0.0, y: 0.0) // Top-to-bottom for all presets
    }
    
    var endPoint: CGPoint {
        return CGPoint(x: 1.0, y: 1.0) // Top-to-bottom for all presets
    }
    
    mutating func toNextGradient(){
        self = self.nextGradient
    }
    
    var nextGradient: GradientPreset{
        guard let color = GradientPreset(rawValue: (self.rawValue + 1) % GradientPreset.allCases.count) else { return GradientPreset.greenToBlue}
        return color
    }
}
