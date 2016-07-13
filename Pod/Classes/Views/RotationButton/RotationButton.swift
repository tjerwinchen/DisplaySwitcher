//
//  RotationButton.swift
//  YALLayoutTransitioning
//
//  Created by Roman on 02.03.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private let gridStrokeEnd: CGFloat = 0.8
private let listStrokeEnd: CGFloat = 1.0

private let gridLineWidth: CGFloat = 4.0
private let listLineWidth: CGFloat = 2.0

private let stepHeightDelta: CGFloat = 0.3

private let itemsCount: Int = 6

public class RotationButton: UIButton {
    
    @IBInspectable var lineColor: UIColor = .green()
    
    private let lineLayer1 = CAShapeLayer()
    private let lineLayer2 = CAShapeLayer()
    private let lineLayer3 = CAShapeLayer()
    private let lineLayer4 = CAShapeLayer()
    private let lineLayer5 = CAShapeLayer()
    private let lineLayer6 = CAShapeLayer()
    
    private let lineLayers: [CAShapeLayer] = {
        var lineLayers = [CAShapeLayer]()
        for index in 0..<itemsCount {
            let lineLayer = CAShapeLayer()
            lineLayers.append(lineLayer)
        }
        
        return lineLayers
    }()
    
    public var animationDuration: TimeInterval = 0.25 //default value
    
    override public var isSelected: Bool {
        didSet {
            animateRotation()
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        for index in 0..<itemsCount {
            layer.addSublayer(lineLayers[index])
        }
        drawLine()
    }
    
    func animateRotation() {
        UIView.animate(withDuration: animationDuration) {
            if self.isSelected {
                self.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
                for index in 0..<itemsCount {
                    let lineLayer = self.lineLayers[index]
                    lineLayer.strokeEnd = gridStrokeEnd
                    lineLayer.lineWidth = gridLineWidth
                }
            } else {
                self.transform = CGAffineTransform.identity
               for index in 0..<itemsCount {
                    let lineLayer = self.lineLayers[index]
                    lineLayer.strokeEnd = listStrokeEnd
                    lineLayer.lineWidth = listLineWidth
                }
            }
            
            let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
            strokeEndAnimation.duration = self.animationDuration
            
            let lineWidthAnimation = CABasicAnimation(keyPath: "lineWidth")
            lineWidthAnimation.duration = self.animationDuration
            
            for index in 0..<itemsCount {
                let lineLayer = self.lineLayers[index]
                lineLayer.add(strokeEndAnimation, forKey: nil)
                lineLayer.add(lineWidthAnimation, forKey: nil)
            }
        }
    }
    
    func drawLine() {
        var path = UIBezierPath()
        var heightDelta: CGFloat = 0.2
        for index in 0..<itemsCount {
            let lineLayer = lineLayers[index]
            var offsetX: CGFloat = 0.0
            if index % 2 == 0 {
                if index > 0 {
                    heightDelta += stepHeightDelta
                }
            } else {
                offsetX = bounds.width
            }
            path = UIBezierPath()
            path.move(to: CGPoint(x: offsetX, y: bounds.height * heightDelta))
            path.addLine(to: CGPoint(x: bounds.width / 2, y: bounds.height * heightDelta))
            lineLayer.path = path.cgPath
            lineLayer.strokeColor = lineColor.cgColor
            lineLayer.lineWidth = listLineWidth
        }
    }
    
}
