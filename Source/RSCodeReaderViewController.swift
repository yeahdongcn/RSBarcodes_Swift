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
    
    var ticker: NSTimer?
    
    public var isCrazyMode = true
    var isCrazyModeStarted = false
    var lensPosition: Float = 0
    
    // MARK: Public methods
    
    public func hasFlash() -> Bool {
        if let d = self.device {
            return d.hasFlash
        }
        return false
    }
    
    public func hasTorch() -> Bool {
        if let d = self.device {
            return d.hasTorch
        }
        return false
    }
    
    public func toggleTorch() {
        if self.hasTorch() {
            self.session.beginConfiguration()
            self.device.lockForConfiguration(nil)
            
            if self.device.torchMode == AVCaptureTorchMode.Off {
                self.device.torchMode = AVCaptureTorchMode.On
            } else if self.device.torchMode == AVCaptureTorchMode.On {
                self.device.torchMode = AVCaptureTorchMode.Off
            }
            
            self.device.unlockForConfiguration()
            self.session.commitConfiguration()
        }
    }
    
    // MARK: Private methods
    
    class func interfaceOrientationToVideoOrientation(orientation : UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch (orientation) {
        case .Unknown:
            fallthrough
        case .Portrait:
            return AVCaptureVideoOrientation.Portrait
        case .PortraitUpsideDown:
            return AVCaptureVideoOrientation.PortraitUpsideDown
        case .LandscapeLeft:
            return AVCaptureVideoOrientation.LandscapeLeft
        case .LandscapeRight:
            return AVCaptureVideoOrientation.LandscapeRight
        }
    }
    
    func autoUpdateLensPosition() {
        self.lensPosition += 0.01
        if self.lensPosition > 1 {
            self.lensPosition = 0
        }
        if device.lockForConfiguration(nil) {
            self.device.setFocusModeLockedWithLensPosition(self.lensPosition, completionHandler: nil)
            device.unlockForConfiguration()
        }
        if session.running {
            let when = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(USEC_PER_SEC)))
            dispatch_after(when, dispatch_get_main_queue(), {
                self.autoUpdateLensPosition()
            })
        }
    }
    
    func onTick() {
        if let t = self.ticker {
            t.invalidate()
        }
        self.cornersLayer.cornersArray = []
    }
    
    func onTap(gesture: UITapGestureRecognizer) {
        let tapPoint = gesture.locationInView(self.view)
        let focusPoint = CGPointMake(
            tapPoint.x / self.view.bounds.size.width,
            tapPoint.y / self.view.bounds.size.height)
        
        if let d = self.device {
            if d.lockForConfiguration(nil) {
                if d.focusPointOfInterestSupported {
                    d.focusPointOfInterest = focusPoint
                } else {
                    println("Focus point of interest not supported.")
                }
                if self.isCrazyMode {
                    if d.isFocusModeSupported(.Locked) {
                        d.focusMode = .Locked
                    } else {
                        println("Locked focus not supported.")
                    }
                    if !self.isCrazyModeStarted {
                        self.isCrazyModeStarted = true
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.autoUpdateLensPosition()
                        })
                    }
                } else {
                    if d.isFocusModeSupported(.ContinuousAutoFocus) {
                        d.focusMode = .ContinuousAutoFocus
                    } else if d.isFocusModeSupported(.AutoFocus) {
                        d.focusMode = .AutoFocus
                    } else {
                        println("Auto focus not supported.")
                    }
                }
                if d.autoFocusRangeRestrictionSupported {
                    d.autoFocusRangeRestriction = .None
                } else {
                    println("Auto focus range restriction not supported.")
                }
                d.unlockForConfiguration()
                self.focusMarkLayer.point = tapPoint
            }
        }
        
        if let h = self.tapHandler {
            h(tapPoint)
        }
    }
    
    func onApplicationWillEnterForeground() {
        self.session.startRunning()
    }
    
    func onApplicationDidEnterBackground() {
        self.session.stopRunning()
    }
    
    // MARK: Deinitialization
    
    deinit {
        println("RSCodeReaderViewController deinit")
    }
    
    // MARK: View lifecycle
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let l = self.videoPreviewLayer {
            let videoOrientation = RSCodeReaderViewController.interfaceOrientationToVideoOrientation(UIApplication.sharedApplication().statusBarOrientation)
            if l.connection.supportsVideoOrientation
                && l.connection.videoOrientation != videoOrientation {
                    l.connection.videoOrientation = videoOrientation
            }
        }
    }
    
    override public func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        let frame = CGRectMake(0, 0, size.width, size.height)
        if let l = self.videoPreviewLayer {
            l.frame = frame
        }
        if let l = self.focusMarkLayer {
            l.frame = frame
        }
        if let l = self.cornersLayer {
            l.frame = frame
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        
        var error : NSError?
        let input = AVCaptureDeviceInput(device: self.device, error: &error)
        if let e = error {
            println(e.description)
            return
        }
        
        if let d = self.device {
            if d.lockForConfiguration(nil) {
                if self.device.isFocusModeSupported(.ContinuousAutoFocus) {
                    self.device.focusMode = .ContinuousAutoFocus
                }
                if self.device.autoFocusRangeRestrictionSupported {
                    self.device.autoFocusRangeRestriction = .Near
                }
                self.device.unlockForConfiguration()
            }
        }
        
        if self.session.canAddInput(input) {
            self.session.addInput(input)
        }
        
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        if let l = self.videoPreviewLayer {
            l.videoGravity = AVLayerVideoGravityResizeAspectFill
            l.frame = self.view.bounds
            self.view.layer.addSublayer(l)
        }
        
        let queue = dispatch_queue_create("com.pdq.rsbarcodes.metadata", DISPATCH_QUEUE_CONCURRENT)
        self.output.setMetadataObjectsDelegate(self, queue: queue)
        if self.session.canAddOutput(self.output) {
            self.session.addOutput(self.output)
            self.output.metadataObjectTypes = self.output.availableMetadataObjectTypes
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "onTap:")
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        self.focusMarkLayer.frame = self.view.bounds
        self.view.layer.addSublayer(self.focusMarkLayer)
        
        self.cornersLayer.frame = self.view.bounds
        self.view.layer.addSublayer(self.cornersLayer)
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onApplicationWillEnterForeground", name:UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onApplicationDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        self.session.startRunning()
    }
    
    override public func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        self.session.stopRunning()
    }
    
    // MARK: AVCaptureMetadataOutputObjectsDelegate
    
    public func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        var barcodeObjects : Array<AVMetadataMachineReadableCodeObject> = []
        var cornersArray : Array<[AnyObject]> = []
        for metadataObject : AnyObject in metadataObjects {
            if let l = self.videoPreviewLayer {
                let transformedMetadataObject = l.transformedMetadataObjectForMetadataObject(metadataObject as AVMetadataObject)
                if transformedMetadataObject.isKindOfClass(AVMetadataMachineReadableCodeObject.self) {
                    let barcodeObject = transformedMetadataObject as AVMetadataMachineReadableCodeObject
                    barcodeObjects.append(barcodeObject)
                    cornersArray.append(barcodeObject.corners)
                }
            }
        }
        
        self.cornersLayer.cornersArray = cornersArray
        
        if barcodeObjects.count > 0 {
            if let h = self.barcodesHandler {
                h(barcodeObjects)
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let t = self.ticker {
                t.invalidate()
            }
            self.ticker = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: "onTick", userInfo: nil, repeats: true)
        })
    }
}
