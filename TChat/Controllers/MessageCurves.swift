//
//  BezierCurvers.swift
//  TChat
//
//  Created by Артем Сарычев on 23.06.21.
//

import Foundation
import UIKit

class MessageCurves: UIView {

    private var lineWidth: CGFloat {
        return 6
    }
    
    var samples: [Float] = []
    var startX: CGFloat = 0
    var startY: CGFloat = 3
    var endX: CGFloat = 0
    var arrayOfVariables: [UIBezierPath] = []
    var previousHeight: CGFloat = 0

    func drawLine(pathVariable: UIBezierPath, startX: CGFloat, startY: CGFloat, endX: CGFloat){
        
        pathVariable.move(to: CGPoint(x: startX, y: startY))
        pathVariable.addLine(to: CGPoint(x:endX , y: startY))
        pathVariable.close()
        self.tintColor.setStroke()
        pathVariable.lineWidth = lineWidth
        pathVariable.lineJoinStyle = .round
        pathVariable.stroke()
        pathVariable.fill()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
            previousHeight = bounds.height
            drawLines()
    }

    override func draw(_ rect: CGRect) {
        drawLines()
        self.setNeedsDisplay()
        self.setNeedsDisplay(rect)
    }
    
    func drawLines(){
        let centerX: CGFloat = self.bounds.width / 2
        self.startX = 0
        self.startY = 3
        self.endX = 0
        arrayOfVariables.forEach({$0.removeAllPoints()})
        arrayOfVariables.removeAll()
        
        for _ in 0..<13 {
            let path = UIBezierPath()
            arrayOfVariables.append(path)
        }
        
        let spacing = (self.bounds.height / 13) - lineWidth
        for i in 0..<arrayOfVariables.count{
            
            var lineStart: CGFloat = 0//centerX * CGFloat(self.array[i])
            if CGFloat(self.samples[i]) > 0.9{
                lineStart = centerX * 0.9
            }else{
                lineStart = centerX * CGFloat(self.samples[i])
            }
            drawLine(pathVariable: arrayOfVariables[i], startX: centerX - lineStart + 1, startY: self.startY, endX: centerX + lineStart - 1)
            
            self.startY += (spacing + lineWidth)
            
        
        }
    }
}

