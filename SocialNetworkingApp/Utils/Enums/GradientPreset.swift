//
//  GradientPreset.swift
//  SocialNetworkingApp
//
//  Created by Philips on 12/08/25.
//


import UIKit

// Define a protocol to ensure each gradient preset provides the necessary properties.
protocol GradientRepresentable {
    var colors: [CGColor] { get }
    var locations: [NSNumber]? { get }
    var startPoint: CGPoint { get }
    var endPoint: CGPoint { get }
}

enum GradientPreset: Int, CaseIterable, GradientRepresentable{
    case sunrise
    case nightSky
    case oceanBlue
    
    var colors: [CGColor] {
        switch self {
        case .sunrise:
            return [
                UIColor(red: 0.9, green: 0.5, blue: 0.3, alpha: 1.0).cgColor, // Top: A warm orange
                UIColor(red: 1.0, green: 0.8, blue: 0.5, alpha: 1.0).cgColor, // Middle: A soft peach
                UIColor(red: 1.0, green: 0.9, blue: 0.8, alpha: 1.0).cgColor  // Bottom: A light cream
            ]
        case .nightSky:
            return [
                UIColor(red: 0.05, green: 0.1, blue: 0.2, alpha: 1.0).cgColor, // Top: Dark blue
                UIColor(red: 0.2, green: 0.3, blue: 0.4, alpha: 1.0).cgColor,  // Middle: Lighter blue-grey
                UIColor(red: 0.4, green: 0.5, blue: 0.6, alpha: 1.0).cgColor   // Bottom: Soft grey-blue
            ]
        case .oceanBlue:
            return [
                UIColor(red: 0.0, green: 0.4, blue: 0.7, alpha: 1.0).cgColor, // Top: Deep blue
                UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1.0).cgColor  // Bottom: Lighter blue
            ]
        }
    }
    
    var locations: [NSNumber]? {
        switch self {
        case .sunrise:
            return [0.0, 0.5, 1.0]
        case .nightSky:
            return [0.0, 0.5, 1.0]
        case .oceanBlue:
            return [0.0, 1.0]
        }
    }
    
    var startPoint: CGPoint {
        return CGPoint(x: 0.5, y: 0.0) // Top-to-bottom for all presets
    }
    
    var endPoint: CGPoint {
        return CGPoint(x: 0.5, y: 1.0) // Top-to-bottom for all presets
    }
    
    mutating func toNextGradient(){
        self = self.nextGradient
    }
    
    var nextGradient: GradientPreset{
        guard let color = GradientPreset(rawValue: (self.rawValue + 1) % GradientPreset.allCases.count) else { return GradientPreset.sunrise}
        return color
    }
}
