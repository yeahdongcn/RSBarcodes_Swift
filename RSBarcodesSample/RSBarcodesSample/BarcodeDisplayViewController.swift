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
    
    let contents = "123456"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = contents
        
        var image: UIImage? = RSCode128Generator(codeTable: .Auto).generateCode(contents, machineReadableCodeObjectType: AVMetadataObjectTypeCode128Code)
        if let i = image {
            self.barcodeView.image = RSAbstractCodeGenerator.resizeImage(i, scale: 3.0)
        }
    }
}
