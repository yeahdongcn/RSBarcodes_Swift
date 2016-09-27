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
    
    var contents: String = "http://www.zai360.com/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = contents
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let gen = RSUnifiedCodeGenerator.shared
        gen.fillColor = UIColor.white
        gen.strokeColor = UIColor.black
        print ("generating image with barcode: " + contents)
        if let image = gen.generateCode(contents, machineReadableCodeObjectType: AVMetadataObjectTypeQRCode) {
            self.imageDisplayed.layer.borderWidth = 1
            self.imageDisplayed.image = RSAbstractCodeGenerator.resizeImage(image, targetSize: self.imageDisplayed.bounds.size, contentMode: UIViewContentMode.bottomRight)
        }
    }
}
