//
//  RSCodeReaderViewController.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/12/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit
import AVFoundation

public class RSCodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    public lazy var device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    public lazy var output = AVCaptureMetadataOutput()
    public lazy var session = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    public lazy var focusMarkLayer = RSFocusMarkLayer()
    public lazy var cornersLayer = RSCornersLayer()
    
    public var tapHandler: ((CGPoint) -> Void)?
    public var barcodesHandler: ((Array<AVMetadataMachineReadableCodeObject>) -> Void)?
    
    var validator: NSTimer?
    
    // MARK: Private methods
    
    class func InterfaceOrientationToVideoOrientation(orientation : UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        var videoOrientation = AVCaptureVideoOrientation.Portrait
        switch (orientation) {
        case .PortraitUpsideDown:
            videoOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
        case .LandscapeLeft:
            videoOrientation = AVCaptureVideoOrientation.LandscapeLeft
        case .LandscapeRight:
            videoOrientation = AVCaptureVideoOrientation.LandscapeRight
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
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let videoOrientation = RSCodeReaderViewController.InterfaceOrientationToVideoOrientation(UIApplication.sharedApplication().statusBarOrientation)
        if videoPreviewLayer != nil
            && videoPreviewLayer!.connection.supportsVideoOrientation
            && videoPreviewLayer!.connection.videoOrientation != videoOrientation {
                videoPreviewLayer!.connection.videoOrientation = videoOrientation
        }
    }
    
    override public func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        if videoPreviewLayer != nil {
            videoPreviewLayer!.frame = CGRectMake(0, 0, size.width, size.height)
        }
    }
    
    override public func viewDidLoad() {
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
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onApplicationWillEnterForeground", name:UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onApplicationDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        session.startRunning()
    }
    
    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        session.stopRunning()
    }
    
    // MARK: AVCaptureMetadataOutputObjectsDelegate
    
    public func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
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
            self.validator = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "onTick", userInfo: nil, repeats: true)
        })
    }
}
