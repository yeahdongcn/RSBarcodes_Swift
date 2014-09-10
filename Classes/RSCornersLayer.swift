//
//  RSCornersLayer.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/13/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit
import QuartzCore

class RSCornersLayer: CALayer {
    var strokeColor = UIColor.greenColor().CGColor
    var strokeWidth: CGFloat = 2
    var drawingCornersArray: Array<Array<CGPoint>> = []
    var cornersArray: Array<[AnyObject]> = [] {
        willSet {
            dispatch_async(dispatch_get_main_queue(), {
                self.setNeedsDisplay()
            })
        }
    }
    
    override func drawInContext(ctx: CGContext!) {
        objc_sync_enter(self)
        
        CGContextSaveGState(ctx)
        
        CGContextSetShouldAntialias(ctx, true)
        CGContextSetAllowsAntialiasing(ctx, true)
        CGContextSetFillColorWithColor(ctx, UIColor.clearColor().CGColor)
        CGContextSetStrokeColorWithColor(ctx, strokeColor)
        CGContextSetLineWidth(ctx, strokeWidth)
        
        for corners in cornersArray {
            for i in 0...corners.count {
                var idx = i
                if i == corners.count {
                    idx = 0
                }
                var dict = corners[idx] as NSDictionary
                
                let x = CGFloat((dict.objectForKey("X") as NSNumber).floatValue)
                let y = CGFloat((dict.objectForKey("Y") as NSNumber).floatValue)
                if i == 0 {
                    CGContextMoveToPoint(ctx, x, y)
                } else {
                    CGContextAddLineToPoint(ctx, x, y)
                }
            }
        }
        
        CGContextDrawPath(ctx, kCGPathFillStroke)
        
        CGContextRestoreGState(ctx)
        
        objc_sync_exit(self)
    }
}
