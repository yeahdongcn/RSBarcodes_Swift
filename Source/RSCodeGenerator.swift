//
//  RSCodeGenerator.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/10/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreImage

let DIGITS_STRING = "0123456789"
let BARCODE_DEFAULT_HEIGHT = 28

// Controls the amount of additional data encoded in the output image to provide error correction.
// Higher levels of error correction result in larger output images but allow larger areas of the code to be damaged or obscured without.
public enum InputCorrectionLevel: String {
    case Low     = "L" // 7%
    case Medium  = "M" // 15% default
    case Quarter = "Q" // 25%
    case High    = "H" // 30%
}

// Code generators are required to provide these two functions.
public protocol RSCodeGenerator {
    /** The fill (background) color of the generated barcode. */
    var fillColor: UIColor {get set}
    
    /** The stroke color of the generated barcode. */
    var strokeColor: UIColor {get set}
    
    /** Check whether the given contents are valid. */
    func isValid(_ contents:String) -> Bool
    
    /** Generate code image using the given machine readable code object and correction level. */
    func generateCode(_ machineReadableCodeObject:AVMetadataMachineReadableCodeObject, inputCorrectionLevel:InputCorrectionLevel, targetSize: CGSize?) -> UIImage?
    
    /** Generate code image using the given machine readable code object. */
    func generateCode(_ machineReadableCodeObject:AVMetadataMachineReadableCodeObject, targetSize: CGSize?) -> UIImage?
    
    /** Generate code image using the given machine readable code object type, contents and correction level. */
    func generateCode(_ contents:String, inputCorrectionLevel:InputCorrectionLevel, machineReadableCodeObjectType:String, targetSize: CGSize?) -> UIImage?
    
    /** Generate code image using the given machine readable code object type and contents. */
    func generateCode(_ contents:String, machineReadableCodeObjectType:String, targetSize: CGSize?) -> UIImage?
}

// Check digit are not required for all code generators.
// UPC-E is using check digit to valid the contents to be encoded.
// Code39Mod43, Code93 and Code128 is using check digit to encode barcode.
public protocol RSCheckDigitGenerator {
    func checkDigit(_ contents:String) -> String
}

// Abstract code generator, provides default functions for validations and generations.
open class RSAbstractCodeGenerator : RSCodeGenerator {
    
    open var fillColor: UIColor = UIColor.white
    open var strokeColor: UIColor = UIColor.black
    
    // Check whether the given contents are valid.
    open func isValid(_ contents:String) -> Bool {
        let length = contents.length()
        if length > 0 {
            for i in 0..<length {
                if !DIGITS_STRING.contains(contents[i]) {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    // Barcode initiator, subclass should return its own value.
    open func initiator() -> String {
        return ""
    }
    
    // Barcode terminator, subclass should return its own value.
    open func terminator() -> String {
        return ""
    }
    
    // Barcode content, subclass should return its own value.
    open func barcode(_ contents:String) -> String {
        return ""
    }
    
    // Composer for combining barcode initiator, contents, terminator together.
    func completeBarcode(_ barcode:String) -> String {
        return self.initiator() + barcode + self.terminator()
    }
    
    // Drawer for completed barcode.
    func drawCompleteBarcode(_ completeBarcode:String, targetSize: CGSize? = nil) -> UIImage? {
        let length:Int = completeBarcode.length()
        if length <= 0 {
            return nil
        }
        
        // Values taken from CIImage generated AVMetadataObjectTypePDF417Code type image
        // Top spacing          = 1.5
        // Bottom spacing       = 2
        // Left & right spacing = 2
        let width = length + 4
        // Calculate the correct aspect ratio, so that the resulting image can be resized to the target size
        var height = BARCODE_DEFAULT_HEIGHT
        if let targetSize = targetSize {
            height = Int(targetSize.height / targetSize.width * CGFloat(width))
        }
        let size = CGSize(width: CGFloat(width), height: CGFloat(height))
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.setShouldAntialias(false)
            
            self.fillColor.setFill()
            self.strokeColor.setStroke()
            
            context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
            context.setLineWidth(1)
            
            for i in 0..<length {
                if completeBarcode[i] == "1" {
                    let x = i + (2 + 1)
                    context.move(to: CGPoint(x: CGFloat(x), y: 1.5))
                    context.addLine(to: CGPoint(x: CGFloat(x), y: size.height - 2))
                }
            }
            context.drawPath(using: CGPathDrawingMode.fillStroke)
            let barcode = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let targetSize = targetSize, let barcode = barcode {
                return RSAbstractCodeGenerator.resizeImage(barcode, targetSize: targetSize, contentMode: UIView.ContentMode.bottomRight)
            }
            
            return barcode
        } else {
            return nil
        }
    }
    
    // RSCodeGenerator
    
    open func generateCode(_ machineReadableCodeObject:AVMetadataMachineReadableCodeObject, inputCorrectionLevel: InputCorrectionLevel, targetSize: CGSize? = nil) -> UIImage? {
        return self.generateCode(machineReadableCodeObject.stringValue!, inputCorrectionLevel: inputCorrectionLevel, machineReadableCodeObjectType: machineReadableCodeObject.type.rawValue, targetSize: targetSize)
    }
    
    open func generateCode(_ machineReadableCodeObject:AVMetadataMachineReadableCodeObject, targetSize: CGSize? = nil) -> UIImage? {
        return self.generateCode(machineReadableCodeObject, inputCorrectionLevel: .Medium, targetSize: targetSize)
    }
    
    open func generateCode(_ contents:String, inputCorrectionLevel:InputCorrectionLevel, machineReadableCodeObjectType:String, targetSize: CGSize? = nil) -> UIImage? {
        if self.isValid(contents) {
            return self.drawCompleteBarcode(self.completeBarcode(self.barcode(contents)), targetSize: targetSize)
        }
        return nil
    }
    
    open func generateCode(_ contents:String, machineReadableCodeObjectType:String, targetSize: CGSize? = nil) -> UIImage? {
        return self.generateCode(contents, inputCorrectionLevel: .Medium, machineReadableCodeObjectType: machineReadableCodeObjectType, targetSize: targetSize)
    }
    
    // Class funcs
    
    // Get CIFilter name by machine readable code object type
    open class func filterName(_ machineReadableCodeObjectType:String) -> String {
        if machineReadableCodeObjectType == AVMetadataObject.ObjectType.qr.rawValue {
            return "CIQRCodeGenerator"
        } else if machineReadableCodeObjectType == AVMetadataObject.ObjectType.pdf417.rawValue {
            return "CIPDF417BarcodeGenerator"
        } else if machineReadableCodeObjectType == AVMetadataObject.ObjectType.aztec.rawValue {
            return "CIAztecCodeGenerator"
        } else if machineReadableCodeObjectType == AVMetadataObject.ObjectType.code128.rawValue {
            return "CICode128BarcodeGenerator"
        } else {
            return ""
        }
    }
    
    // Generate CI related code image
    open class func generateCode(_ contents:String, inputCorrectionLevel: InputCorrectionLevel, filterName:String, targetSize: CGSize? = nil, fillColor: UIColor = .white, strokeColor: UIColor = .black) -> UIImage? {
        
        if filterName.length() > 0 {
            if let filter = CIFilter(name: filterName) {
                filter.setDefaults()
                let inputMessage = contents.data(using: String.Encoding.utf8, allowLossyConversion: false)
                filter.setValue(inputMessage, forKey: "inputMessage")
                if filterName == "CIQRCodeGenerator" {
                    filter.setValue(inputCorrectionLevel.rawValue, forKey: "inputCorrectionLevel")
                }

                let outputImage = colorizeImage(filter.outputImage, fillColor, strokeColor)
                
                let transform = createImageTransform(targetSize, outputImage)

                if let outputImage = outputImage?.transformed(by: transform) {
                    if let cgImage = ContextMaker.make().createCGImage(outputImage, from: outputImage.extent) {
                        return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
                    }
                }
            }
        }
        return nil
    }
    
    open class func generateCode(_ contents:String, filterName:String, targetSize: CGSize? = nil, fillColor: UIColor = .white, strokeColor: UIColor = .black) -> UIImage? {
        return self.generateCode(contents, inputCorrectionLevel: .Medium, filterName: filterName, targetSize: targetSize, fillColor: fillColor, strokeColor: strokeColor)
    }
    
    fileprivate static func colorizeImage(_ outputImage: CIImage?, _ fillColor: UIColor, _ strokeColor: UIColor) -> CIImage? {
        if let colorFilter = CIFilter(name: "CIFalseColor") {
            colorFilter.setValue(outputImage, forKey: "inputImage")
            let ciFillColor = CIColor(cgColor: fillColor.cgColor)
            let ciStrokeColor = CIColor(cgColor: strokeColor.cgColor)
            colorFilter.setValue(ciFillColor, forKey: "inputColor1")
            colorFilter.setValue(ciStrokeColor, forKey: "inputColor0")
            return colorFilter.outputImage
        }
        return outputImage
    }
    
    fileprivate static func createImageTransform(_ targetSize: CGSize?, _ image: CIImage?) -> CGAffineTransform {
        if let targetSize = targetSize, let image = image {
            let scaleX: CGFloat = targetSize.width / image.extent.size.width
            let scaleY: CGFloat = targetSize.height / image.extent.size.height
            let scale = min(scaleX, scaleY)
            return CGAffineTransform(scaleX: scale, y: scale)
        }
        return CGAffineTransform(scaleX: 1, y: 1)
    }

    // Resize image
    open class func resizeImage(_ source:UIImage, scale:CGFloat) -> UIImage? {
        let width = source.size.width * scale
        let height = source.size.height * scale
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.interpolationQuality = .none
        source.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        let target = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return target
    }
    
    open class func resizeImage(_ source:UIImage, targetSize:CGSize, contentMode:UIView.ContentMode) -> UIImage? {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var width = targetSize.width
        var height = targetSize.height
        if contentMode == .scaleToFill { // contents scaled to fill
            // Nothing to do
        } else if contentMode == .scaleAspectFill { // contents scaled to fill with fixed aspect. some portion of content may be clipped.
            let targtLength  = (targetSize.height > targetSize.width)   ? targetSize.height  : targetSize.width
            let sourceLength = (source.size.height < source.size.width) ? source.size.height : source.size.width
            let fillScale = targtLength / sourceLength
            width = source.size.width * fillScale
            height = source.size.height * fillScale
            x = (targetSize.width  - width)  / 2.0
            y = (targetSize.height - height) / 2.0
        } else { // contents scaled to fit with fixed aspect. remainder is transparent
            let scaledRect = AVMakeRect(aspectRatio: source.size, insideRect: CGRect(x: 0.0, y: 0.0, width: targetSize.width, height: targetSize.height))
            width = scaledRect.width
            height = scaledRect.height
            if contentMode == .scaleAspectFit
                || contentMode == .redraw
                || contentMode == .center {
                x = (targetSize.width  - width)  / 2.0
                y = (targetSize.height - height) / 2.0
            } else if contentMode == .top {
                x = (targetSize.width  - width)  / 2.0
                y = 0
            } else if contentMode == .bottom {
                x = (targetSize.width  - width)  / 2.0
                y = targetSize.height - height
            } else if contentMode == .left {
                x = 0
                y = (targetSize.height - height) / 2.0
            } else if contentMode == .right {
                x = targetSize.width  - width
                y = (targetSize.height - height) / 2.0
            } else if contentMode == .topLeft {
                x = 0
                y = 0
            } else if contentMode == .topRight {
                x = targetSize.width  - width
                y = 0
            } else if contentMode == .bottomLeft {
                x = 0
                y = targetSize.height - height
            } else if contentMode == .bottomRight {
                x = targetSize.width  - width
                y = targetSize.height - height
            }
        }
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.interpolationQuality = CGInterpolationQuality.none
        source.draw(in: CGRect(x: x, y: y, width: width, height: height))
        let target = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return target
    }
}
