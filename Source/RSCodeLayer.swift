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
    
    override public func draw(in ctx: CGContext) {
        if let code = self.code {
            ctx.saveGState()
            
            ctx.draw(code.cgImage!, in: self.bounds)
            
            ctx.restoreGState()
        }
    }
}
