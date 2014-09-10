//
//  RSCodeLayer.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/13/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit
import QuartzCore

class RSCodeLayer: CALayer {
    var code: UIImage?
    
    override func drawInContext(ctx: CGContext!) {
        if code == nil {
            return
        }
        
        CGContextSaveGState(ctx);
        
        CGContextDrawImage(ctx, self.bounds, code!.CGImage);
        
        CGContextRestoreGState(ctx);
    }
}
