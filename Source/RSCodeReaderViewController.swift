//
//  RSCodeReaderViewController.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/12/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit
import AVFoundation

open class RSCodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    public var device: AVCaptureDevice? = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    public var output = AVCaptureMetadataOutput()
    public var session = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    public var focusMarkLayer = RSFocusMarkLayer()
    public var cornersLayer = RSCornersLayer()
    
    public var tapHandler: ((CGPoint) -> Void)?
    public var barcodesHandler: ((Array<AVMetadataMachineReadableCodeObject>) -> Void)?
    
    var ticker: Timer?
    
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
                try self.device?.lockForConfiguration()
            } catch _ {
            }
            
            if self.device?.torchMode == .off {
                self.device?.torchMode = .on
            } else if self.device?.torchMode == .on {
                self.device?.torchMode = .off
            }
            
            self.device?.unlockForConfiguration()
            self.session.commitConfiguration()
            
            return self.device!.torchMode == .on
        }
        return false
    }
    
    // MARK: Private methods
    
    class func interfaceOrientationToVideoOrientation(_ orientation : UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch (orientation) {
        case .unknown:
            fallthrough
        case .portrait:
            return AVCaptureVideoOrientation.portrait
        case .portraitUpsideDown:
            return AVCaptureVideoOrientation.portraitUpsideDown
        case .landscapeLeft:
            return AVCaptureVideoOrientation.landscapeLeft
        case .landscapeRight:
            return AVCaptureVideoOrientation.landscapeRight
        }
    }
    
    func autoUpdateLensPosition() {
        self.lensPosition += 0.01
        if self.lensPosition > 1 {
            self.lensPosition = 0
        }
        do {
            try device?.lockForConfiguration()
            self.device?.setFocusModeLockedWithLensPosition(self.lensPosition, completionHandler: nil)
            device?.unlockForConfiguration()
        } catch _ {
        }
        if session.isRunning {
            let when = DispatchTime.now() + Double(Int64(10 * Double(USEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: when, execute: {
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
    
    func onTap(_ gesture: UITapGestureRecognizer) {
        let tapPoint = gesture.location(in: self.view)
        let focusPoint = CGPoint(
            x: tapPoint.x / self.view.bounds.size.width,
            y: tapPoint.y / self.view.bounds.size.height)
        
        if let device = self.device {
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = focusPoint
                } else {
                    print("Focus point of interest not supported.")
                }
                if self.isCrazyMode {
                    if device.isFocusModeSupported(.locked) {
                        device.focusMode = .locked
                    } else {
                        print("Locked focus not supported.")
                    }
                    if !self.isCrazyModeStarted {
                        self.isCrazyModeStarted = true
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.autoUpdateLensPosition()
                        })
                    }
                } else {
                    if device.isFocusModeSupported(.continuousAutoFocus) {
                        device.focusMode = .continuousAutoFocus
                    } else if device.isFocusModeSupported(.autoFocus) {
                        device.focusMode = .autoFocus
                    } else {
                        print("Auto focus not supported.")
                    }
                }
                if device.isAutoFocusRangeRestrictionSupported {
                    device.autoFocusRangeRestriction = .none
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
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let videoPreviewLayer = self.videoPreviewLayer {
            let videoOrientation = RSCodeReaderViewController.interfaceOrientationToVideoOrientation(UIApplication.shared.statusBarOrientation)
            if videoPreviewLayer.connection.isVideoOrientationSupported
                && videoPreviewLayer.connection.videoOrientation != videoOrientation {
                    videoPreviewLayer.connection.videoOrientation = videoOrientation
            }
            videoPreviewLayer.frame = self.view.bounds
        }
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        if let videoPreviewLayer = self.videoPreviewLayer {
            videoPreviewLayer.frame = frame
        }
        self.focusMarkLayer.frame = frame
        self.cornersLayer.frame = frame
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        
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
                if ((self.device?.isFocusModeSupported(.continuousAutoFocus)) != nil) {
                    self.device?.focusMode = .continuousAutoFocus
                }
                if ((self.device?.isAutoFocusRangeRestrictionSupported) != nil) {
                    self.device?.autoFocusRangeRestriction = .near
                }
                self.device?.unlockForConfiguration()
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
        
        let queue = DispatchQueue(label: "com.pdq.rsbarcodes.metadata", attributes: DispatchQueue.Attributes.concurrent)
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
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(RSCodeReaderViewController.onApplicationWillEnterForeground), name:NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RSCodeReaderViewController.onApplicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        self.session.startRunning()
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        self.session.stopRunning()
    }
    
    // MARK: AVCaptureMetadataOutputObjectsDelegate
    public func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        var barcodeObjects : Array<AVMetadataMachineReadableCodeObject> = []
        var cornersArray : Array<[AnyObject]> = []
        for metadataObject : AnyObject in metadataObjects as [AnyObject]! {
            if let videoPreviewLayer = self.videoPreviewLayer {
                let transformedMetadataObject = videoPreviewLayer.transformedMetadataObject(for: metadataObject as! AVMetadataObject)
                if ((transformedMetadataObject?.isKind(of: AVMetadataMachineReadableCodeObject.self)) != nil) {
                    let barcodeObject = transformedMetadataObject as! AVMetadataMachineReadableCodeObject
                    barcodeObjects.append(barcodeObject)
                    cornersArray.append(barcodeObject.corners as [AnyObject])
                }
            }
        }
        
        self.cornersLayer.cornersArray = cornersArray
        
        if barcodeObjects.count > 0 {
            if let barcodesHandler = self.barcodesHandler {
                barcodesHandler(barcodeObjects)
            }
        }
        
        DispatchQueue.main.async(execute: { () -> Void in
            if let ticker = self.ticker {
                ticker.invalidate()
            }
            self.ticker = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(RSCodeReaderViewController.onTick), userInfo: nil, repeats: true)
        })
    }
}
