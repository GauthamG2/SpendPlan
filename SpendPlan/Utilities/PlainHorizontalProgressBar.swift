//
//  LinearProgressBar.swift
//  SpendPlan
//
//  Created by Gautham Sritharan on 2021-05-24.
//

import Foundation
import UIKit

@IBDesignable
class PlainHorizontalProgressBar: UIView {
    @IBInspectable var color: UIColor = .gray {
        didSet { setNeedsDisplay() }
    }
    
    var progress: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }
    
    private let progressLayer = CALayer()
    private let backgroundMask = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
        layer.addSublayer(progressLayer)
//        backgroundMask.borderWidth = 1
//        backgroundMask.borderColor = UIColor(red:0, green:0, blue:0, alpha: 1).cgColor
    }
    
    override func draw(_ rect: CGRect) {
        backgroundMask.path = UIBezierPath(roundedRect: rect, cornerRadius: rect.height * 0.25).cgPath
        layer.mask = backgroundMask
        backgroundMask.borderWidth = 1
        backgroundMask.borderColor = UIColor(red:0, green:0, blue:0, alpha: 1).cgColor
        
        let progressRect = CGRect(origin: .zero, size: CGSize(width: rect.width * progress, height: rect.height))
        
        progressLayer.frame = progressRect
        progressLayer.backgroundColor = color.cgColor
//        progressLayer.borderWidth = 1
//        progressLayer.borderColor = UIColor(red:0, green:0, blue:0, alpha: 1).cgColor
    }
}
