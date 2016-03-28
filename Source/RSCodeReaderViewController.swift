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
    
    public var isCrazyMode = false
    var isCrazyModeStarted = false
    var lensPosition: Float = 0
    
    // MARK: Public methods
    
    public func hasFlash() -> Bool {
        if let device = self.device {
            return device.hasFlash
        }
        return false
    }
    
    public func hasTorch() -> Bool {
        if let device = self.device {
            return device.hasTorch
        }
        return false
    }
    
    public func toggleTorch() -> Bool {
        if self.hasTorch() {
            self.session.beginConfiguration()
            do {
                try self.device.lockForConfiguration()
            } catch _ {
            }
            
            if self.device.torchMode == .Off {
                self.device.torchMode = .On
            } else if self.device.torchMode == .On {
                self.device.torchMode = .Off
            }
            
            self.device.unlockForConfiguration()
            self.session.commitConfiguration()
            
            return self.device.torchMode == .On
        }
        return false
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
        do {
            try device.lockForConfiguration()
            self.device.setFocusModeLockedWithLensPosition(self.lensPosition, completionHandler: nil)
            device.unlockForConfiguration()
        } catch _ {
        }
        if session.running {
            let when = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(USEC_PER_SEC)))
            dispatch_after(when, dispatch_get_main_queue(), {
                self.autoUpdateLensPosition()
            })
        }
    }
    
    func onTick() {
        if let ticker = self.ticker {
            ticker.invalidate()
        }
        self.cornersLayer.cornersArray = []
    }
    
    func onTap(gesture: UITapGestureRecognizer) {
        let tapPoint = gesture.locationInView(self.view)
        let focusPoint = CGPointMake(
            tapPoint.x / self.view.bounds.size.width,
            tapPoint.y / self.view.bounds.size.height)
        
        if let device = self.device {
            do {
                try device.lockForConfiguration()
                if device.focusPointOfInterestSupported {
                    device.focusPointOfInterest = focusPoint
                } else {
                    print("Focus point of interest not supported.")
                }
                if self.isCrazyMode {
                    if device.isFocusModeSupported(.Locked) {
                        device.focusMode = .Locked
                    } else {
                        print("Locked focus not supported.")
                    }
                    if !self.isCrazyModeStarted {
                        self.isCrazyModeStarted = true
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.autoUpdateLensPosition()
                        })
                    }
                } else {
                    if device.isFocusModeSupported(.ContinuousAutoFocus) {
                        device.focusMode = .ContinuousAutoFocus
                    } else if device.isFocusModeSupported(.AutoFocus) {
                        device.focusMode = .AutoFocus
                    } else {
                        print("Auto focus not supported.")
                    }
                }
                if device.autoFocusRangeRestrictionSupported {
                    device.autoFocusRangeRestriction = .None
                } else {
                    print("Auto focus range restriction not supported.")
                }
                device.unlockForConfiguration()
                self.focusMarkLayer.point = tapPoint
            } catch _ {
            }
        }
        
        if let tapHandler = self.tapHandler {
            tapHandler(tapPoint)
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
        print("RSCodeReaderViewController deinit")
    }
    
    // MARK: View lifecycle
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let videoPreviewLayer = self.videoPreviewLayer {
            let videoOrientation = RSCodeReaderViewController.interfaceOrientationToVideoOrientation(UIApplication.sharedApplication().statusBarOrientation)
            if videoPreviewLayer.connection.supportsVideoOrientation
                && videoPreviewLayer.connection.videoOrientation != videoOrientation {
                    videoPreviewLayer.connection.videoOrientation = videoOrientation
            }
            videoPreviewLayer.frame = self.view.bounds
        }
    }
    
    override public func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        let frame = CGRectMake(0, 0, size.width, size.height)
        if let videoPreviewLayer = self.videoPreviewLayer {
            videoPreviewLayer.frame = frame
        }
        self.focusMarkLayer.frame = frame
        self.cornersLayer.frame = frame
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        
        var error : NSError?
        let input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: self.device)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        if let error = error {
            print(error.description)
            return
        }
        
        if let device = self.device {
            do {
                try device.lockForConfiguration()
                if self.device.isFocusModeSupported(.ContinuousAutoFocus) {
                    self.device.focusMode = .ContinuousAutoFocus
                }
                if self.device.autoFocusRangeRestrictionSupported {
                    self.device.autoFocusRangeRestriction = .Near
                }
                self.device.unlockForConfiguration()
            } catch _ {
            }
        }
        
        if self.session.canAddInput(input) {
            self.session.addInput(input)
        }
        
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        if let videoPreviewLayer = self.videoPreviewLayer {
            videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer.frame = self.view.bounds
            self.view.layer.addSublayer(videoPreviewLayer)
        }
        
        let queue = dispatch_queue_create("com.pdq.rsbarcodes.metadata", DISPATCH_QUEUE_CONCURRENT)
        self.output.setMetadataObjectsDelegate(self, queue: queue)
        if self.session.canAddOutput(self.output) {
            self.session.addOutput(self.output)
            self.output.metadataObjectTypes = self.output.availableMetadataObjectTypes
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RSCodeReaderViewController.onTap(_:)))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        self.focusMarkLayer.frame = self.view.bounds
        self.view.layer.addSublayer(self.focusMarkLayer)
        
        self.cornersLayer.frame = self.view.bounds
        self.view.layer.addSublayer(self.cornersLayer)
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RSCodeReaderViewController.onApplicationWillEnterForeground), name:UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RSCodeReaderViewController.onApplicationDidEnterBackground), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
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
            if let videoPreviewLayer = self.videoPreviewLayer {
                let transformedMetadataObject = videoPreviewLayer.transformedMetadataObjectForMetadataObject(metadataObject as! AVMetadataObject)
                if transformedMetadataObject.isKindOfClass(AVMetadataMachineReadableCodeObject.self) {
                    let barcodeObject = transformedMetadataObject as! AVMetadataMachineReadableCodeObject
                    barcodeObjects.append(barcodeObject)
                    cornersArray.append(barcodeObject.corners)
                }
            }
        }
        
        self.cornersLayer.cornersArray = cornersArray
        
        if barcodeObjects.count > 0 {
            if let barcodesHandler = self.barcodesHandler {
                barcodesHandler(barcodeObjects)
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if let ticker = self.ticker {
                ticker.invalidate()
            }
            self.ticker = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: #selector(RSCodeReaderViewController.onTick), userInfo: nil, repeats: true)
        })
    }
}
