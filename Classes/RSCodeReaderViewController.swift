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
    let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    let session = AVCaptureSession()
    
    let focusMarkLayer = RSFocusMarkLayer()
    let cornersLayer = RSCornersLayer()
    
    var layer: AVCaptureVideoPreviewLayer?
    
    var tapHandler: ((CGPoint) -> Void)?
    var barcodesHandler: ((Array<AVMetadataMachineReadableCodeObject>) -> Void)?
    
    func tap(gesture: UITapGestureRecognizer) {
        let tapPoint = gesture.locationInView(self.view)
        let focusPoint = CGPointMake(
            tapPoint.x / self.view.bounds.size.width,
            tapPoint.y / self.view.bounds.size.height)
        
        if device == nil
            || !device.focusPointOfInterestSupported
            || !device.isFocusModeSupported(.AutoFocus) {
                return
        } else if device.lockForConfiguration(nil) {
            device.focusPointOfInterest = focusPoint
            device.focusMode = .AutoFocus
            device.unlockForConfiguration()
            
            focusMarkLayer.point = tapPoint
            
            if tapHandler != nil {
                tapHandler!(tapPoint)
            }
        }
    }
    
    func appWillEnterForeground() {
        session.startRunning()
    }
    
    func appDidEnterBackground() {
        session.stopRunning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var error : NSError?
        let input = AVCaptureDeviceInput(device: device, error: &error)
        if error != nil {
            println(error!.description)
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        layer = AVCaptureVideoPreviewLayer(session: session)
        layer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        layer!.frame = self.view.bounds
        self.view.layer.addSublayer(layer!)
        
        let output = AVCaptureMetadataOutput()
        let queue = dispatch_queue_create("com.pdq.rsbarcodes.metadata", DISPATCH_QUEUE_CONCURRENT)
        output.setMetadataObjectsDelegate(self, queue: queue)
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.metadataObjectTypes = output.availableMetadataObjectTypes
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: "tap:")
        self.view.addGestureRecognizer(gesture)
        
        focusMarkLayer.frame = self.view.bounds
        self.view.layer.addSublayer(focusMarkLayer)
        
        cornersLayer.frame = self.view.bounds
        self.view.layer.addSublayer(cornersLayer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWillEnterForeground", name:UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        session.startRunning()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        session.stopRunning()
    }
    
    // AVCaptureMetadataOutputObjectsDelegate
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        var barcodeObjects : Array<AVMetadataMachineReadableCodeObject> = []
        var cornersArray : Array<[AnyObject]> = []
        for metadataObject : AnyObject in metadataObjects {
            let transformedMetadataObject = layer!.transformedMetadataObjectForMetadataObject(metadataObject as AVMetadataObject)
            if transformedMetadataObject.isKindOfClass(AVMetadataMachineReadableCodeObject.self) {
                let barcodeObject = transformedMetadataObject as AVMetadataMachineReadableCodeObject
                barcodeObjects.append(barcodeObject)
                cornersArray.append(barcodeObject.corners)
            }
        }
        
        cornersLayer.cornersArray = cornersArray
        
        if barcodeObjects.count > 0 && barcodesHandler != nil {
            barcodesHandler!(barcodeObjects)
        }
    }
}
