//
//  BezierCurvers.swift
//  TChat
//
//  Created by Артем Сарычев on 23.06.21.
//

import Foundation
import UIKit

class MessageCurvesReaded: UIView {

    var array: [Float] = []//[][0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.2, 0.1, 0.2, 0.3]
    var startX: CGFloat = 0
    var startY: CGFloat = 3
    
    var endX: CGFloat = 0
    var endY: CGFloat = 3
    
    var line1 = UIBezierPath()
    var line2 = UIBezierPath()
    var line3 = UIBezierPath()
    var line4 = UIBezierPath()
    var line5 = UIBezierPath()
    var line6 = UIBezierPath()
    var line7 = UIBezierPath()
    var line8 = UIBezierPath()
    var line9 = UIBezierPath()
    var line10 = UIBezierPath()
    var line11 = UIBezierPath()
    var line12 = UIBezierPath()
    var line13 = UIBezierPath()
    
    var arrayOfVariables: [UIBezierPath] = []
    
    func drawLine(pathVariable: UIBezierPath, startX: CGFloat, startY: CGFloat, endX: CGFloat, endY: CGFloat){
        
        pathVariable.move(to: CGPoint(x: startX, y: startY))
        pathVariable.addLine(to: CGPoint(x:endX , y: endY))
        pathVariable.close()
        UIColor.lightGray.setFill()
        UIColor.lightGray.setStroke()
        
        pathVariable.lineWidth = 6.0
        pathVariable.lineJoinStyle = .round
        pathVariable.stroke()
        pathVariable.fill()
    }

    override func draw(_ rect: CGRect) {
        //        // Drawing code
        // let center: CGPoint = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        let centerX: CGFloat = self.bounds.width / 2
        //let centerY: CGFloat = self.bounds.height / 2
        
        arrayOfVariables.append(contentsOf: [line1, line2, line3, line4, line5, line6, line7, line8, line9, line10, line11, line12, line13])
        for i in 0..<arrayOfVariables.count{
            //print(i)
            var lineStart: CGFloat = 0//centerX * CGFloat(self.array[i])
            if CGFloat(self.array[i]) > 0.9{
                lineStart = centerX * 0.9
            }else{
                lineStart = centerX * CGFloat(self.array[i])
            }
            drawLine(pathVariable: arrayOfVariables[i], startX: centerX - lineStart + 1, startY: self.startY, endX: centerX + lineStart - 1, endY: self.endY)
            
            self.startY = self.startY + 12
            self.endY = self.endY + 12
        
        }
    }
}

