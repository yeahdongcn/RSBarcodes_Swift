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
        
        let r = RSUnifiedCodeGenerator.shared.generateCode("123456789", machineReadableCodeObjectType: AVMetadataObjectTypeDataMatrixCode)
        
        println()
    }
}

