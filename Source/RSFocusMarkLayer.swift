//
//  RSFocusMarkLayer.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/13/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit
import QuartzCore

public class RSFocusMarkLayer: CALayer {
    // Use camera.app's focus mark size as default
    public var size = CGSizeMake(76, 76)
    // Use camera.app's focus mark sight as default
    public var sight: CGFloat = 6
    // Use camera.app's focus mark color as default
    public var strokeColor = UIColor(rgba: "#ffcc00").CGColor
    public var strokeWidth: CGFloat = 1
    public var delay: CFTimeInterval = 1
    public var canDraw = false
    
    deinit {
        print("RSFocusMarkLayer deinit")
    }
    
    public var point : CGPoint = CGPointMake(0, 0) {
        didSet {
            dispatch_async(dispatch_get_main_queue(), {
                self.canDraw = true
                self.setNeedsDisplay()
            })
            
            let when = dispatch_time(DISPATCH_TIME_NOW, Int64(self.delay * Double(NSEC_PER_SEC)))
            dispatch_after(when, dispatch_get_main_queue(), {
                self.canDraw = false
                self.setNeedsDisplay()
            })
        }
    }
    
    override public func drawInContext(ctx: CGContext) {
        if !self.canDraw {
            return
        }
        
        CGContextSaveGState(ctx)
        
        CGContextSetShouldAntialias(ctx, true)
        CGContextSetAllowsAntialiasing(ctx, true)
        CGContextSetFillColorWithColor(ctx, UIColor.clearColor().CGColor)
        CGContextSetStrokeColorWithColor(ctx, self.strokeColor)
        CGContextSetLineWidth(ctx, self.strokeWidth)
        
        // Rect
        CGContextStrokeRect(ctx, CGRectMake(self.point.x - self.size.width / 2.0, self.point.y - self.size.height / 2.0, self.size.width, self.size.height))
        
        // Focus
        for i in 0..<4 {
            var endPoint: CGPoint
            switch i {
            case 0:
                CGContextMoveToPoint(ctx, self.point.x, self.point.y - self.size.height / 2.0)
                endPoint = CGPointMake(self.point.x, self.point.y - self.size.height / 2.0 + self.sight)
            case 1:
                CGContextMoveToPoint(ctx, self.point.x, self.point.y + self.size.height / 2.0)
                endPoint = CGPointMake(self.point.x, self.point.y + self.size.height / 2.0 - self.sight)
            case 2:
                CGContextMoveToPoint(ctx, self.point.x - self.size.width / 2.0, self.point.y)
                endPoint = CGPointMake(self.point.x - self.size.width / 2.0 + self.sight, self.point.y)
            case 3:
                CGContextMoveToPoint(ctx, self.point.x + self.size.width / 2.0, self.point.y)
                endPoint = CGPointMake(self.point.x + self.size.width / 2.0 - self.sight, self.point.y)
            default:
                endPoint = CGPointMake(0, 0)
            }
            CGContextAddLineToPoint(ctx, endPoint.x, endPoint.y)
        }
        
        CGContextDrawPath(ctx, CGPathDrawingMode.FillStroke)
        
        CGContextRestoreGState(ctx)
    }
}
