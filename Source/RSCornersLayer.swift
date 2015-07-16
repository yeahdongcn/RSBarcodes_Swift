//
//  RSCornersLayer.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/13/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit
import QuartzCore

public class RSCornersLayer: CALayer {
    public var strokeColor = UIColor.greenColor().CGColor
    public var strokeWidth: CGFloat = 2
    public var drawingCornersArray: Array<Array<CGPoint>> = []
    public var cornersArray: Array<[AnyObject]> = [] {
        willSet {
            dispatch_async(dispatch_get_main_queue(), {
                self.setNeedsDisplay()
            })
        }
    }
    
    override public func drawInContext(ctx: CGContext) {
        objc_sync_enter(self)
        
        CGContextSaveGState(ctx)
        
        CGContextSetShouldAntialias(ctx, true)
        CGContextSetAllowsAntialiasing(ctx, true)
        CGContextSetFillColorWithColor(ctx, UIColor.clearColor().CGColor)
        CGContextSetStrokeColorWithColor(ctx, self.strokeColor)
        CGContextSetLineWidth(ctx, self.strokeWidth)
        
        for corners in self.cornersArray {
            for i in 0...corners.count {
                var idx = i
                if i == corners.count {
                    idx = 0
                }
                let dict = corners[idx] as! NSDictionary
                
                let x = CGFloat((dict.objectForKey("X") as! NSNumber).floatValue)
                let y = CGFloat((dict.objectForKey("Y") as! NSNumber).floatValue)
                if i == 0 {
                    CGContextMoveToPoint(ctx, x, y)
                } else {
                    CGContextAddLineToPoint(ctx, x, y)
                }
            }
        }
        
        CGContextDrawPath(ctx, CGPathDrawingMode.FillStroke)
        
        CGContextRestoreGState(ctx)
        
        objc_sync_exit(self)
    }
}
