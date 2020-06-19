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
    
    var contents: String = "https://github.com/VMwareFusion/nautilus"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = contents
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let gen = RSUnifiedCodeGenerator.shared
        gen.fillColor = UIColor.white
        gen.strokeColor = UIColor.black
        print ("generating image with barcode: " + contents)
        if let image = gen.generateCode("Text Example", machineReadableCodeObjectType: AVMetadataObject.ObjectType.qr.rawValue, targetSize: CGSize(width: 1000, height: 1000)) {
            debugPrint(image.size)
            self.imageDisplayed.layer.borderWidth = 1
            self.imageDisplayed.image = RSAbstractCodeGenerator.resizeImage(image, targetSize: self.imageDisplayed.bounds.size, contentMode: UIView.ContentMode.bottomRight)
        }

    }
}
