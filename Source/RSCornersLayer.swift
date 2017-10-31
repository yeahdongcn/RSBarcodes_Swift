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
                let point = corners[idx] as! CGPoint
                
                if i == 0 {
                    ctx.move(to: point)
                } else {
                    ctx.addLine(to: point)
                }
            }
        }
        
        ctx.drawPath(using: CGPathDrawingMode.fillStroke)
        
        ctx.restoreGState()
        
        objc_sync_exit(self)
    }
}
