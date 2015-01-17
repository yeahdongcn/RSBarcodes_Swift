//
//  BarcodeDisplayViewController.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 15/1/17.
//  Copyright (c) 2015年 P.D.Q. All rights reserved.
//

import UIKit
import AVFoundation
import RSBarcodes

class BarcodeDisplayViewController: UIViewController {

    @IBOutlet var barcodeView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.barcodeView.image = RSCode128Generator(codeTable: .Auto).generateCode("123456", machineReadableCodeObjectType: AVMetadataObjectTypeCode128Code)
    }
}
