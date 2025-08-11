//
//  PerfectOvalView.swift
//  SocialNetworkingApp
//
//  Created by Philips on 11/08/25.
//


import UIKit

class OvalView: UIView {

    private let shapeLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShapeLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupShapeLayer()
    }

    private func setupShapeLayer() {
        self.layer.addSublayer(shapeLayer)
        //shapeLayer.fillColor = UIColor.systemBlue.cgColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Create an ellipse that perfectly fits the view's bounds
        let ovalPath = UIBezierPath(ovalIn: self.bounds)
        shapeLayer.path = ovalPath.cgPath
    }
}
