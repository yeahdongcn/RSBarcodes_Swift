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
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    let focusMarkLayer = RSFocusMarkLayer()
    let cornersLayer = RSCornersLayer()
    
    var tapHandler: ((CGPoint) -> Void)?
    var barcodesHandler: ((Array<AVMetadataMachineReadableCodeObject>) -> Void)?
    
    var validator: NSTimer?
    
    // MARK: Private methods
    
    class func InterfaceOrientationToVideoOrientation(orientation : UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        var videoOrientation = AVCaptureVideoOrientation.Portrait
        switch (orientation) {
        case .PortraitUpsideDown:
            videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
            break
        case .LandscapeLeft:
            videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
            break
        case .LandscapeRight:
            videoOrientation = AVCaptureVideoOrientation.LandscapeRight
            break
        default:
            break
        }
        return videoOrientation
    }
    
    func onTick() {
        validator!.invalidate()
        validator = nil
        
        cornersLayer.cornersArray = []
    }
    
    func onTap(gesture: UITapGestureRecognizer) {
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
    
    func onApplicationWillEnterForeground() {
        session.startRunning()
    }
    
    func onApplicationDidEnterBackground() {
        session.stopRunning()
    }
    
    // MARK: View lifecycle
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let videoOrientation = RSCodeReaderViewController.InterfaceOrientationToVideoOrientation(UIApplication.sharedApplication().statusBarOrientation)
        if videoPreviewLayer != nil
            && videoPreviewLayer!.connection.supportsVideoOrientation
            && videoPreviewLayer!.connection.videoOrientation != videoOrientation {
                videoPreviewLayer!.connection.videoOrientation = videoOrientation
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        if videoPreviewLayer != nil {
            videoPreviewLayer!.frame = CGRectMake(0, 0, size.width, size.height)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        
        var error : NSError?
        let input = AVCaptureDeviceInput(device: device, error: &error)
        if error != nil {
            println(error!.description)
            return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        if videoPreviewLayer != nil {
            videoPreviewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer!.frame = self.view.bounds
            self.view.layer.addSublayer(videoPreviewLayer!)
        }
        
        let output = AVCaptureMetadataOutput()
        let queue = dispatch_queue_create("com.pdq.rsbarcodes.metadata", DISPATCH_QUEUE_CONCURRENT)
        output.setMetadataObjectsDelegate(self, queue: queue)
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.metadataObjectTypes = output.availableMetadataObjectTypes
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: "onTap:")
        self.view.addGestureRecognizer(gesture)
        
        focusMarkLayer.frame = self.view.bounds
        self.view.layer.addSublayer(focusMarkLayer)
        
        cornersLayer.frame = self.view.bounds
        self.view.layer.addSublayer(cornersLayer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onApplicationWillEnterForeground", name:UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onApplicationDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        session.startRunning()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        session.stopRunning()
    }
    
    // MARK: AVCaptureMetadataOutputObjectsDelegate
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        var barcodeObjects : Array<AVMetadataMachineReadableCodeObject> = []
        var cornersArray : Array<[AnyObject]> = []
        for metadataObject : AnyObject in metadataObjects {
            if videoPreviewLayer != nil {
                let transformedMetadataObject = videoPreviewLayer!.transformedMetadataObjectForMetadataObject(metadataObject as AVMetadataObject)
                if transformedMetadataObject.isKindOfClass(AVMetadataMachineReadableCodeObject.self) {
                    let barcodeObject = transformedMetadataObject as AVMetadataMachineReadableCodeObject
                    barcodeObjects.append(barcodeObject)
                    cornersArray.append(barcodeObject.corners)
                }
            }
        }
        
        cornersLayer.cornersArray = cornersArray
        
        if barcodeObjects.count > 0 && barcodesHandler != nil {
            barcodesHandler!(barcodeObjects)
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if self.validator != nil {
                self.validator!.invalidate()
                self.validator = nil
            }
            self.validator = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "onTick", userInfo: nil, repeats: true);
        })
    }
}
