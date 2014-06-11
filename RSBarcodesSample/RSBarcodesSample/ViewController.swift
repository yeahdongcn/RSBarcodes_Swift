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
        
        println(AVMetadataObjectTypeInterleaved2of5Code)
        println(AVMetadataObjectTypeDataMatrixCode)
        
        let g = RSUnifiedCodeGenerator.shared
        
        let c39r = g.generateCode("2166529V", machineReadableCodeObjectType: AVMetadataObjectTypeCode39Code)
        
        let c39m43r = g.generateCode("CODE 39", machineReadableCodeObjectType: AVMetadataObjectTypeCode39Mod43Code)
        
        let ce39r = g.generateCode("R0ckStar", machineReadableCodeObjectType: RSMetadataObjectTypeExtendedCode39Code)
        
        let ean8r = g.generateCode("47112346", machineReadableCodeObjectType: AVMetadataObjectTypeEAN8Code);
        
        let ean13r = g.generateCode("6902890884910", machineReadableCodeObjectType: AVMetadataObjectTypeEAN13Code)
        
        let isbn13r = g.generateCode("9789504200857", machineReadableCodeObjectType: RSMetadataObjectTypeISBN13Code)
        
        let issn13r = g.generateCode("9771234567003", machineReadableCodeObjectType: RSMetadataObjectTypeISSN13Code)
        
        let itf14r = g.generateCode("15400141288763", machineReadableCodeObjectType: AVMetadataObjectTypeITF14Code)
        
        println()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

