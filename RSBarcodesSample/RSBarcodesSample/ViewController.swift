//
//  ViewController.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/10/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let g = RSUnifiedCodeGenerator.shared
        let c39r = g.generateCode("2166529V", machineReadableCodeObjectType: AVMetadataObjectTypeCode39Code)
        println(c39r)
        
        let c39m43r = g.generateCode("CODE 39", machineReadableCodeObjectType: AVMetadataObjectTypeCode39Mod43Code)
        println(c39m43r)
        
        let ce39r = g.generateCode("R0ckStar", machineReadableCodeObjectType: RSMetadataObjectTypeExtendedCode39Code)
        println(ce39r)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

