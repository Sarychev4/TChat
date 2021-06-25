//
//  BezierCurvers.swift
//  TChat
//
//  Created by Артем Сарычев on 23.06.21.
//

import Foundation
import UIKit

class InboxCurves: UIView {

    private var lineWidth: CGFloat {
        return 4
    }
    
    var samples: [Float] = []
    var startX: CGFloat = 2
    var startY: CGFloat = 0
    var endY: CGFloat = 0
    
    var arrayOfVariables: [UIBezierPath] = []
    var previousWidth: CGFloat = 0
 
    func drawLine(pathVariable: UIBezierPath, startX: CGFloat, startY: CGFloat, endY: CGFloat){
        
        pathVariable.move(to: CGPoint(x: startX, y: startY))
        pathVariable.addLine(to: CGPoint(x:startX , y: endY))
        pathVariable.close()
        self.tintColor.setStroke()
        pathVariable.lineWidth = lineWidth
        pathVariable.lineJoinStyle = .round
        pathVariable.stroke()
        pathVariable.fill()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
            previousWidth = bounds.width
            drawLines()
    }
    
    override func draw(_ rect: CGRect) {
        drawLines()
        self.setNeedsDisplay()
        self.setNeedsDisplay(rect)
    }
    
    func drawLines() {
        let centerY: CGFloat = self.bounds.height / 2
        self.startX = 2
        self.startY = 0
        self.endY = 0
        arrayOfVariables.forEach({$0.removeAllPoints()})
        arrayOfVariables.removeAll()
        
        for _ in 0..<25 {
            let path = UIBezierPath()
            arrayOfVariables.append(path)
        }
        
        let spacing = (self.bounds.width / 25) - lineWidth
        for i in 0..<arrayOfVariables.count{
            var lineStart: CGFloat = 0//centerX * CGFloat(self.array[i])
            if CGFloat(self.samples[i]) > 0.9{
                lineStart = centerY * 0.9
            }else{
                lineStart = centerY * CGFloat(self.samples[i])
            }
            drawLine(pathVariable: arrayOfVariables[i], startX: self.startX, startY: centerY - lineStart + 1, endY: centerY + lineStart - 1)
            self.startX += (spacing + lineWidth)
        }
    }
    
}

