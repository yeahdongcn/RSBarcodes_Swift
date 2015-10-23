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
    
    let contents = "AAABBBCCCDDDEEE1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = contents
        
        let gen = RSUnifiedCodeGenerator.shared
        gen.fillColor = UIColor.whiteColor()
        gen.strokeColor = UIColor.blackColor()
        let image: UIImage? = gen.generateCode(contents, machineReadableCodeObjectType: AVMetadataObjectTypeCode128Code)
        if let image = image {
            self.barcodeView.image = RSAbstractCodeGenerator.resizeImage(image, scale: 1.0)
        }
    }
}
