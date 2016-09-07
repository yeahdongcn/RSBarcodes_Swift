//
//  RSCodeLayer.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/13/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit
import QuartzCore

public class RSCodeLayer: CALayer {
    var code: UIImage?
    
    override public func drawInContext(ctx: CGContext) {
        if let code = self.code {
            CGContextSaveGState(ctx)
            if let img = code.CGImage {
                CGContextDrawImage(ctx, self.bounds, img)
            }
            
            CGContextRestoreGState(ctx)
        }
    }
}
