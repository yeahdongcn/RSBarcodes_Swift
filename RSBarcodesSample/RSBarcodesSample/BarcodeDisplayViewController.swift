//
//  BarcodeDisplayViewController.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 15/1/17.
//
//  Updated by Jarvie8176 on 01/21/2016
//
//  Copyright (c) 2015年 P.D.Q. All rights reserved.
//

import UIKit
import AVFoundation
import RSBarcodes

class BarcodeDisplayViewController: UIViewController {
    @IBOutlet weak var imageDisplayed: UIImageView!
    
    var contents:String = "http://www.zai360.com/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = contents
        
        let gen = RSUnifiedCodeGenerator.shared
        gen.fillColor = UIColor.whiteColor()
        gen.strokeColor = UIColor.blackColor()
        print ("generating image with barcode: " + contents)
        let image: UIImage? = gen.generateCode(contents, machineReadableCodeObjectType: AVMetadataObjectTypeQRCode)
        
        if (image != nil) {
            self.imageDisplayed.layer.borderWidth = 1
            self.imageDisplayed.image = RSAbstractCodeGenerator.resizeImage(image!, targetSize: self.imageDisplayed.bounds.size, contentMode: UIViewContentMode.BottomRight)
        }
    }
}
