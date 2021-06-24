//
//  BezierCurvers.swift
//  TChat
//
//  Created by Артем Сарычев on 23.06.21.
//

import Foundation
import UIKit

class InboxCurves: UIView {

    var array: [Float] = []//[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.2, 0.1, 0.2, 0.3]
    var startX: CGFloat = 2
    var startY: CGFloat = 0
    
    var endX: CGFloat = 2
    var endY: CGFloat = 0
    
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
    var line14 = UIBezierPath()
    var line15 = UIBezierPath()
    var line16 = UIBezierPath()
    var line17 = UIBezierPath()
    var line18 = UIBezierPath()
    var line19 = UIBezierPath()
    var line20 = UIBezierPath()
    var line21 = UIBezierPath()
    var line22 = UIBezierPath()
    var line23 = UIBezierPath()
    var line24 = UIBezierPath()
    var line25 = UIBezierPath()
    var line26 = UIBezierPath()
    var line27 = UIBezierPath()
    var line28 = UIBezierPath()
    var line29 = UIBezierPath()
    var line30 = UIBezierPath()
    
    var arrayOfVariables: [UIBezierPath] = []
    
    func drawLine(pathVariable: UIBezierPath, startX: CGFloat, startY: CGFloat, endX: CGFloat, endY: CGFloat){
        
        pathVariable.move(to: CGPoint(x: startX, y: startY))
        pathVariable.addLine(to: CGPoint(x:endX , y: endY))
        pathVariable.close()
        UIColor.systemBlue.setFill()
        UIColor.systemBlue.setStroke()
        pathVariable.lineWidth = 4.0
        pathVariable.lineJoinStyle = .round
        pathVariable.stroke()
        pathVariable.fill()
    }

    override func draw(_ rect: CGRect) {
        //        // Drawing code
        // let center: CGPoint = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
       // let centerX: CGFloat = self.bounds.width / 2
        let centerY: CGFloat = self.bounds.height / 2
        
        arrayOfVariables.append(contentsOf: [line1, line2, line3, line4, line5, line6, line7, line8, line9, line10, line11, line12, line13, line14, line15, line16, line17, line18, line19, line20, line21, line22, line23, line24, line25, line26, line27, line28, line29, line30])
        for i in 0..<arrayOfVariables.count{
            //print(i)
            var lineStart: CGFloat = 0//centerX * CGFloat(self.array[i])
            if CGFloat(self.array[i]) > 0.9{
                lineStart = centerY * 0.9
            }else{
                lineStart = centerY * CGFloat(self.array[i])
            }
            drawLine(pathVariable: arrayOfVariables[i], startX: self.startX, startY: centerY - lineStart + 1, endX: self.endX, endY: centerY + lineStart - 1)
            
            self.startX = self.startX + 8
            self.endX = self.endX + 8
        
        }
    }
}

