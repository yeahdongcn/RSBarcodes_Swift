//
//  RSCornersLayer.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/13/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit
import QuartzCore

open class RSCornersLayer: CALayer {
    open var strokeColor = UIColor.green.cgColor
    open var strokeWidth: CGFloat = 2
    open var drawingCornersArray: Array<Array<CGPoint>> = []
    open var cornersArray: Array<[Any]> = [] {
        willSet {
            DispatchQueue.main.async(execute: {
                self.setNeedsDisplay()
            })
        }
    }
    
    override open func draw(in ctx: CGContext) {
        objc_sync_enter(self)
        
        ctx.saveGState()
        
        ctx.setShouldAntialias(true)
        ctx.setAllowsAntialiasing(true)
        ctx.setFillColor(UIColor.clear.cgColor)
        ctx.setStrokeColor(self.strokeColor)
        ctx.setLineWidth(self.strokeWidth)
        
        for corners in self.cornersArray {
            for i in 0...corners.count {
                var idx = i
                if i == corners.count {
                    idx = 0
                }
                let dict = corners[idx] as! NSDictionary
                
                let x = CGFloat((dict.object(forKey: "X") as! NSNumber).floatValue)
                let y = CGFloat((dict.object(forKey: "Y") as! NSNumber).floatValue)
                if i == 0 {
                    ctx.move(to: CGPoint(x: x, y: y))
                } else {
                    ctx.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
        
        ctx.drawPath(using: CGPathDrawingMode.fillStroke)
        
        ctx.restoreGState()
        
        objc_sync_exit(self)
    }
}
