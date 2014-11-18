//
//  ViewController.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/10/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: RSCodeReaderViewController {
    
    func click(sender: AnyObject?) {
        println("Close")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.focusMarkLayer.strokeColor = UIColor.redColor().CGColor
        
        self.cornersLayer.strokeColor = UIColor.yellowColor().CGColor
        
        self.tapHandler = { point in
            println(point)
        }
        
        self.barcodesHandler = { barcodes in
            for barcode in barcodes {
                println(barcode)
            }
        }
        
        let button = UIButton(frame: CGRectMake(0, 0, 100, 100))
        button.setTitle("Close", forState: UIControlState.Normal)
        button.addTarget(self, action: "click:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button)
    }
}

