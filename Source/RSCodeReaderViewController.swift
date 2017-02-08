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
    
    open var device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    open var output = AVCaptureMetadataOutput()
    open var session = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    open var focusMarkLayer = RSFocusMarkLayer()
    open var cornersLayer = RSCornersLayer()
    
    open var tapHandler: ((CGPoint) -> Void)?
    open var barcodesHandler: ((Array<AVMetadataMachineReadableCodeObject>) -> Void)?
    
    var ticker: Timer?
    
    open var isCrazyMode = false
    var isCrazyModeStarted = false
    var lensPosition: Float = 0
    
    fileprivate struct Platform {
        static let isSimulator: Bool = {
            var isSim = false
            #if arch(i386) || arch(x86_64)
                isSim = true
            #endif
            return isSim
        }()
    }
    
    // MARK: Public methods
    
    open func hasFlash() -> Bool {
        if let device = self.device {
            return device.hasFlash
        }
        return false
    }
    
    open func hasTorch() -> Bool {
        if let device = self.device {
            return device.hasTorch
        }
        return false
    }
    
    open func switchCamera() -> AVCaptureDevicePosition {
        if !Platform.isSimulator {
            self.session.stopRunning()
            let captureDevice = self.captureDevice()
            if let device = captureDevice {
                self.device = device
            }
            self.setupCamera()
			self.view.setNeedsLayout()
            self.session.startRunning()
            if let device = self.device {
                return device.position
            } else {
                return .unspecified
            }
        } else {
            return .unspecified
        }
    }
    
    open func toggleTorch() -> Bool {
        if self.hasTorch() {
            self.session.beginConfiguration()
            if let device = self.device {
                do {
                    try device.lockForConfiguration()
                } catch _ {
                }
                
                if device.torchMode == .off {
                    device.torchMode = .on
                } else if device.torchMode == .on {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
                self.session.commitConfiguration()
                
                return device.torchMode == .on
            }
        }
        return false
    }
    
    // MARK: Private methods
    
    func captureDevice() -> AVCaptureDevice? {
        if let device = self.device {
            if device.position == AVCaptureDevicePosition.back {
                for device: AVCaptureDevice in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as! Array {
                    if device.position == AVCaptureDevicePosition.front {
                        return device
                    }
                }
            } else if device.position == AVCaptureDevicePosition.front {
                for device: AVCaptureDevice in AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as! Array {
                    if device.position == AVCaptureDevicePosition.back {
                        return device
                    }
                }
            }
        }
        return nil
    }
    
    func setupCamera() {
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
                if device.isFocusModeSupported(.continuousAutoFocus) {
                    device.focusMode = .continuousAutoFocus
                }
                if device.isAutoFocusRangeRestrictionSupported {
                    device.autoFocusRangeRestriction = .near
                }
                device.unlockForConfiguration()
            } catch _ {
            }
        }
        
        // Remove previous added inputs from session
        for input in self.session.inputs {
            self.session.removeInput(input as! AVCaptureInput)
        }
        if self.session.canAddInput(input) {
            self.session.addInput(input)
        }
        
        if let videoPreviewLayer = self.videoPreviewLayer {
            videoPreviewLayer.removeFromSuperlayer()
        }
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        if let videoPreviewLayer = self.videoPreviewLayer {
            videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer.frame = self.view.bounds
            self.view.layer.insertSublayer(videoPreviewLayer, at: 0)
        }
        
        if self.output.metadataObjectsDelegate == nil
            || self.output.metadataObjectsCallbackQueue == nil {
            let queue = DispatchQueue(label: "com.pdq.rsbarcodes.metadata", attributes: DispatchQueue.Attributes.concurrent)
            self.output.setMetadataObjectsDelegate(self, queue: queue)
        }
        // Remove previous added outputs from session
        var metadataObjectTypes: [AnyObject]?
        for output in self.session.outputs {
            metadataObjectTypes = (output as AnyObject).metadataObjectTypes as [AnyObject]?
            self.session.removeOutput(output as! AVCaptureOutput)
        }
        if self.session.canAddOutput(self.output) {
            self.session.addOutput(self.output)
            if let metadataObjectTypes = metadataObjectTypes {
                self.output.metadataObjectTypes = metadataObjectTypes
            } else  {
                self.output.metadataObjectTypes = self.output.availableMetadataObjectTypes
            }
        }
		
		reloadVideoOrientation()
    }
    
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
    
	func reloadVideoOrientation() {
		guard let videoPreviewLayer = self.videoPreviewLayer else {
			return
		}
		guard videoPreviewLayer.connection.isVideoOrientationSupported else {
			print("isVideoOrientationSupported is false")
			return
		}
		
		let statusBarOrientation = UIApplication.shared.statusBarOrientation
		let videoOrientation = RSCodeReaderViewController.interfaceOrientationToVideoOrientation(statusBarOrientation)
		
		if videoPreviewLayer.connection.videoOrientation == videoOrientation {
			print("no change to videoOrientation")
			return
		}
		
		videoPreviewLayer.connection.videoOrientation = videoOrientation
		videoPreviewLayer.removeAllAnimations()
	}
	
    func autoUpdateLensPosition() {
        self.lensPosition += 0.01
        if self.lensPosition > 1 {
            self.lensPosition = 0
        }
        if let device = self.device {
            do {
                try device.lockForConfiguration()
                device.setFocusModeLockedWithLensPosition(self.lensPosition, completionHandler: nil)
                device.unlockForConfiguration()
            } catch _ {
            }
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
        if !Platform.isSimulator {
            self.session.startRunning()
        }
    }
    
    func onApplicationDidEnterBackground() {
        if !Platform.isSimulator {
            self.session.stopRunning()
        }
    }
    
    // MARK: Deinitialization
    
    deinit {
        print("RSCodeReaderViewController deinit")
    }
    
    // MARK: View lifecycle
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
		let frame = self.view.bounds
		self.videoPreviewLayer?.frame = frame
		self.focusMarkLayer.frame = frame
		self.cornersLayer.frame = frame
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
		coordinator.animate(alongsideTransition: nil, completion: { [weak self] _ in
			DispatchQueue.main.async {
				self?.reloadVideoOrientation()
			}
		})
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        
        self.setupCamera()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RSCodeReaderViewController.onTap(_:)))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        self.focusMarkLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(self.focusMarkLayer, above: self.videoPreviewLayer)
        
        self.cornersLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(self.cornersLayer, above: self.videoPreviewLayer)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(RSCodeReaderViewController.onApplicationWillEnterForeground), name:NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RSCodeReaderViewController.onApplicationDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        if !Platform.isSimulator {
            self.session.startRunning()
        }
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        if !Platform.isSimulator {
            self.session.stopRunning()
        }
    }
    
    // MARK: AVCaptureMetadataOutputObjectsDelegate
    
    open func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        var barcodeObjects : Array<AVMetadataMachineReadableCodeObject> = []
        var cornersArray : Array<[Any]> = []
        for metadataObject in metadataObjects {
            if let videoPreviewLayer = self.videoPreviewLayer {
                if let transformedMetadataObject = videoPreviewLayer.transformedMetadataObject(for: metadataObject as! AVMetadataObject) {
                    if transformedMetadataObject.isKind(of: AVMetadataMachineReadableCodeObject.self) {
                        let barcodeObject = transformedMetadataObject as! AVMetadataMachineReadableCodeObject
                        barcodeObjects.append(barcodeObject)
                        cornersArray.append(barcodeObject.corners)
                    }
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
