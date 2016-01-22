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
    
    var contents:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = contents
        
        let gen = RSUnifiedCodeGenerator.shared
        gen.fillColor = UIColor.whiteColor()
        gen.strokeColor = UIColor.blackColor()
        print ("generating image with barcode: " + contents)
        let image: UIImage? = gen.generateCode(contents, machineReadableCodeObjectType: AVMetadataObjectTypeCode128Code)
        
        if (image != nil) {
            self.imageDisplayed.image = RSAbstractCodeGenerator.resizeImage(image!, scale: 1.0)
        }
    }
}
