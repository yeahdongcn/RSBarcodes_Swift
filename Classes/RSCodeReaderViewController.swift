//
//  RSCodeReaderViewController.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/12/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit
import AVFoundation

class RSCodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    let session = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var error : NSError?
        let input = AVCaptureDeviceInput(device: device, error: &error)
        if error {
            println(error.description)
            exit(0)
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = AVLayerVideoGravityResizeAspectFill
        layer.frame = self.view.bounds
        self.view.layer.addSublayer(layer)
        
        let output = AVCaptureMetadataOutput()
        let queue = dispatch_queue_create("com.pdq.rsbarcodes.metadata", DISPATCH_QUEUE_SERIAL);
        output.setMetadataObjectsDelegate(self, queue: queue)
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.metadataObjectTypes = output.availableMetadataObjectTypes
        }
        session.startRunning()
    }
    
    // AVCaptureMetadataOutputObjectsDelegate
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: AnyObject[]!, fromConnection connection: AVCaptureConnection!) {
        
    }
}
