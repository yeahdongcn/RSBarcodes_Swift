//
//  RSCodeReaderViewController.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/12/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import AVFoundation
import UIKit

open class RSCodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
   @objc open var device = AVCaptureDevice.default(for: AVMediaType.video)
   @objc open var output = AVCaptureMetadataOutput()
   @objc open var session = AVCaptureSession()
   @objc var videoPreviewLayer: AVCaptureVideoPreviewLayer?
	
   @objc open var focusMarkLayer = RSFocusMarkLayer()
   @objc open var cornersLayer = RSCornersLayer()
	
   @objc open var tapHandler: ((CGPoint) -> Void)?
   @objc open var barcodesHandler: (([AVMetadataMachineReadableCodeObject]) -> Void)?
	
   @objc var ticker: Timer?
	
   @objc open var isCrazyMode = false
   @objc var isCrazyModeStarted = false
   @objc var lensPosition: Float = 0
	
   fileprivate enum Platform {
      static let isSimulator: Bool = {
         var isSim = false
         #if arch(i386) || arch(x86_64)
            isSim = true
         #endif
         return isSim
      }()
   }
	
   // MARK: Public methods
	
   @objc open func hasFlash() -> Bool {
      if let device = self.device {
         return device.hasFlash
      }
      return false
   }
	
   @objc open func hasTorch() -> Bool {
      if let device = self.device {
         return device.hasTorch
      }
      return false
   }
	
   @objc open func switchCamera() -> AVCaptureDevice.Position {
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

   @discardableResult
   @objc open func toggleTorch() -> Bool {
      if self.hasTorch() {
         self.session.beginConfiguration()
         if let device = self.device {
            do {
               try device.lockForConfiguration()
            } catch _ {}
				
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
   
   @objc func captureDevice() -> AVCaptureDevice? {
      if let device = self.device {
         guard device.position == .back || device.position == .front else {
            return nil
         }
         let position = device.position == .back ? AVCaptureDevice.Position.front : AVCaptureDevice.Position.back
         if #available(iOS 10.0, *) {
            let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: position).devices
            return devices.first
         } else {
            for device: AVCaptureDevice in AVCaptureDevice.devices(for: AVMediaType.video) {
               if device.position == position {
                  return device
               }
            }
         }
      }
      return nil
   }
	
   @objc func setupCamera() {
      var error: NSError?
      let input: AVCaptureDeviceInput!
      do {
         guard let device = self.device else { return }
         input = try AVCaptureDeviceInput(device: device)
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
         } catch _ {}
      }
		
      // Remove previous added inputs from session
      for input in self.session.inputs {
         self.session.removeInput(input)
      }
      if self.session.canAddInput(input) {
         self.session.addInput(input)
      }
		
      if let videoPreviewLayer = self.videoPreviewLayer {
         videoPreviewLayer.removeFromSuperlayer()
      }
      self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
      if let videoPreviewLayer = self.videoPreviewLayer {
         videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
         videoPreviewLayer.frame = self.view.bounds
         self.view.layer.insertSublayer(videoPreviewLayer, at: 0)
      }
		
      if self.output.metadataObjectsDelegate == nil
         || self.output.metadataObjectsCallbackQueue == nil
      {
         let queue = DispatchQueue(label: "com.pdq.rsbarcodes.metadata", attributes: DispatchQueue.Attributes.concurrent)
         self.output.setMetadataObjectsDelegate(self, queue: queue)
      }
      // Remove previous added outputs from session
      var metadataObjectTypes: [AVMetadataObject.ObjectType]?
      for output in self.session.outputs {
         if let output = output as? AVCaptureMetadataOutput {
            metadataObjectTypes = output.metadataObjectTypes
         }
         self.session.removeOutput(output)
      }
      if self.session.canAddOutput(self.output) {
         self.session.addOutput(self.output)
         if let metadataObjectTypes = metadataObjectTypes {
            self.output.metadataObjectTypes = metadataObjectTypes
         } else {
            self.output.metadataObjectTypes = self.output.availableMetadataObjectTypes
         }
      }
		
      self.reloadVideoOrientation()
   }
	
   @objc class func interfaceOrientationToVideoOrientation(_ orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
      switch orientation {
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
      @unknown default:
         return AVCaptureVideoOrientation.portrait
      }
   }
	
   @objc func reloadVideoOrientation() {
      guard let videoPreviewLayer = self.videoPreviewLayer else {
         return
      }
      guard (videoPreviewLayer.connection?.isVideoOrientationSupported)! else {
         print("isVideoOrientationSupported is false")
         return
      }
		
      let statusBarOrientation = UIApplication.shared.statusBarOrientation
      let videoOrientation = RSCodeReaderViewController.interfaceOrientationToVideoOrientation(statusBarOrientation)
		
      if videoPreviewLayer.connection?.videoOrientation == videoOrientation {
         print("no change to videoOrientation")
         return
      }
		
      videoPreviewLayer.connection?.videoOrientation = videoOrientation
      videoPreviewLayer.removeAllAnimations()
   }
	
   @objc func autoUpdateLensPosition() {
      self.lensPosition += 0.01
      if self.lensPosition > 1 {
         self.lensPosition = 0
      }
      if let device = self.device {
         do {
            try device.lockForConfiguration()
            device.setFocusModeLocked(lensPosition: self.lensPosition, completionHandler: nil)
            device.unlockForConfiguration()
         } catch _ {}
      }
      if self.session.isRunning {
         let when = DispatchTime.now() + Double(Int64(10 * Double(USEC_PER_SEC))) / Double(NSEC_PER_SEC)
         DispatchQueue.main.asyncAfter(deadline: when) {
            self.autoUpdateLensPosition()
         }
      }
   }
	
   @objc func onTick() {
      if let ticker = self.ticker {
         ticker.invalidate()
      }
      self.cornersLayer.cornersArray = []
   }
	
   @objc func onTap(_ gesture: UITapGestureRecognizer) {
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
                  DispatchQueue.main.async { () -> Void in
                     self.autoUpdateLensPosition()
                  }
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
         } catch _ {}
      }
		
      if let tapHandler = self.tapHandler {
         tapHandler(tapPoint)
      }
   }
	
   @objc func onApplicationWillEnterForeground() {
      if !Platform.isSimulator {
         self.session.startRunning()
      }
   }
	
   @objc func onApplicationDidEnterBackground() {
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
		
      NotificationCenter.default.addObserver(self, selector: #selector(RSCodeReaderViewController.onApplicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(RSCodeReaderViewController.onApplicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
		
      if !Platform.isSimulator {
         self.session.startRunning()
      }
   }
	
   override open func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)

      NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
      NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
      if !Platform.isSimulator {
         self.session.stopRunning()
      }
   }
	
   // MARK: AVCaptureMetadataOutputObjectsDelegate

   public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
      var barcodeObjects: [AVMetadataMachineReadableCodeObject] = []
      var cornersArray: [[Any]] = []
      for metadataObject in metadataObjects {
         if let videoPreviewLayer = self.videoPreviewLayer {
            if let transformedMetadataObject = videoPreviewLayer.transformedMetadataObject(for: metadataObject) {
               if transformedMetadataObject.isKind(of: AVMetadataMachineReadableCodeObject.self) {
                  let barcodeObject = transformedMetadataObject as! AVMetadataMachineReadableCodeObject
                  barcodeObjects.append(barcodeObject)
                  #if !targetEnvironment(simulator)
                     cornersArray.append(barcodeObject.corners)
                  #endif
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
		
      DispatchQueue.main.async { () -> Void in
         if let ticker = self.ticker {
            ticker.invalidate()
         }
         self.ticker = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(RSCodeReaderViewController.onTick), userInfo: nil, repeats: true)
      }
   }
}
