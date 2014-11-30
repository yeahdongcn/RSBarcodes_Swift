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
    public var size = CGSizeMake(76, 76) // Use camera.app's focus mark size
    public var sight: CGFloat = 6 // Use camera.app's focus mark sight
    public var strokeColor = UIColor(rgba: "#ffcc00").CGColor // Use camera.app's focus mark color
    public var strokeWidth: CGFloat = 1
    public var delay: CFTimeInterval = 1
    public var canDraw = false
    
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
    
    override public func drawInContext(ctx: CGContext!) {
        if !canDraw {
            return
        }
        
        CGContextSaveGState(ctx)
        
        CGContextSetShouldAntialias(ctx, true)
        CGContextSetAllowsAntialiasing(ctx, true)
        CGContextSetFillColorWithColor(ctx, UIColor.clearColor().CGColor)
        CGContextSetStrokeColorWithColor(ctx, strokeColor)
        CGContextSetLineWidth(ctx, strokeWidth)
        
        // Rect
        CGContextStrokeRect(ctx, CGRectMake(point.x - size.width / 2.0, point.y - size.height / 2.0, size.width, size.height))
        
        // Focus
        for i in 0..<4 {
            var endPoint: CGPoint
            switch i {
            case 0:
                CGContextMoveToPoint(ctx, point.x, point.y - size.height / 2.0)
                endPoint = CGPointMake(point.x, point.y - size.height / 2.0 + sight)
            case 1:
                CGContextMoveToPoint(ctx, point.x, point.y + size.height / 2.0)
                endPoint = CGPointMake(point.x, point.y + size.height / 2.0 - sight)
            case 2:
                CGContextMoveToPoint(ctx, point.x - size.width / 2.0, point.y)
                endPoint = CGPointMake(point.x - size.width / 2.0 + sight, point.y)
            case 3:
                CGContextMoveToPoint(ctx, point.x + size.width / 2.0, point.y)
                endPoint = CGPointMake(point.x + size.width / 2.0 - sight, point.y)
            default:
                endPoint = CGPointMake(0, 0)
            }
            CGContextAddLineToPoint(ctx, endPoint.x, endPoint.y)
        }
        
        CGContextDrawPath(ctx, kCGPathFillStroke)
        
        CGContextRestoreGState(ctx)
    }
}
