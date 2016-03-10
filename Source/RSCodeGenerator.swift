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

// Controls the amount of additional data encoded in the output image to provide error correction.
// Higher levels of error correction result in larger output images but allow larger areas of the code to be damaged or obscured without.
public enum InputCorrectionLevel: String {
    case Low = "L"     // 7%
    case Medium = "M"  // 15% default
    case Quarter = "Q" // 25%
    case High = "H"    // 30%
}

// Code generators are required to provide these two functions.
public protocol RSCodeGenerator {
    /** The fill (background) color of the generated barcode. */
    var fillColor: UIColor {get set}
    
    /** The stroke color of the generated barcode. */
    var strokeColor: UIColor {get set}
    
    /** Check whether the given contents are valid. */
    func isValid(contents:String) -> Bool
    
    /** Generate code image using the given machine readable code object and correction level. */
    func generateCode(machineReadableCodeObject:AVMetadataMachineReadableCodeObject, inputCorrectionLevel:InputCorrectionLevel) -> UIImage?
    
    /** Generate code image using the given machine readable code object. */
    func generateCode(machineReadableCodeObject:AVMetadataMachineReadableCodeObject) -> UIImage?
    
    /** Generate code image using the given machine readable code object type, contents and correction level. */
    func generateCode(contents:String, inputCorrectionLevel:InputCorrectionLevel, machineReadableCodeObjectType:String) -> UIImage?
    
    /** Generate code image using the given machine readable code object type and contents. */
    func generateCode(contents:String, machineReadableCodeObjectType:String) -> UIImage?
}

// Check digit are not required for all code generators.
// UPC-E is using check digit to valid the contents to be encoded.
// Code39Mod43, Code93 and Code128 is using check digit to encode barcode.
public protocol RSCheckDigitGenerator {
    func checkDigit(contents:String) -> String
}

// Abstract code generator, provides default functions for validations and generations.
public class RSAbstractCodeGenerator : RSCodeGenerator {
    
    public var fillColor: UIColor = UIColor.whiteColor()
    public var strokeColor: UIColor = UIColor.blackColor()
    
    // Check whether the given contents are valid.
    public func isValid(contents:String) -> Bool {
        let length = contents.length()
        if length > 0 {
            for i in 0..<length {
                let character = contents[i]
                if !DIGITS_STRING.contains(character!) {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    // Barcode initiator, subclass should return its own value.
    public func initiator() -> String {
        return ""
    }
    
    // Barcode terminator, subclass should return its own value.
    public func terminator() -> String {
        return ""
    }
    
    // Barcode content, subclass should return its own value.
    public func barcode(contents:String) -> String {
        return ""
    }
    
    // Composer for combining barcode initiator, contents, terminator together.
    func completeBarcode(barcode:String) -> String {
        return self.initiator() + barcode + self.terminator()
    }
    
    // Drawer for completed barcode.
    func drawCompleteBarcode(completeBarcode:String) -> UIImage? {
        let length:Int = completeBarcode.length()
        if length <= 0 {
            return nil
        }
        
        // Values taken from CIImage generated AVMetadataObjectTypePDF417Code type image
        // Top spacing          = 1.5
        // Bottom spacing       = 2
        // Left & right spacing = 2
        // Height               = 28
        let width = length + 4
        let size = CGSizeMake(CGFloat(width), 28)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetShouldAntialias(context, false)
        
        self.fillColor.setFill()
        self.strokeColor.setStroke()
        
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height))
        CGContextSetLineWidth(context, 1)
        
        for i in 0..<length {
            let character = completeBarcode[i]
            if character == "1" {
                let x = i + (2 + 1)
                CGContextMoveToPoint(context, CGFloat(x), 1.5)
                CGContextAddLineToPoint(context, CGFloat(x), size.height - 2)
            }
        }
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
        let barcode = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return barcode
    }
    
    // RSCodeGenerator
    
    public func generateCode(machineReadableCodeObject:AVMetadataMachineReadableCodeObject, inputCorrectionLevel: InputCorrectionLevel) -> UIImage? {
        return self.generateCode(machineReadableCodeObject.stringValue, inputCorrectionLevel: inputCorrectionLevel, machineReadableCodeObjectType: machineReadableCodeObject.type)
    }
    
    public func generateCode(machineReadableCodeObject:AVMetadataMachineReadableCodeObject) -> UIImage? {
        return self.generateCode(machineReadableCodeObject, inputCorrectionLevel: .Medium)
    }
    
    public func generateCode(contents:String, inputCorrectionLevel:InputCorrectionLevel, machineReadableCodeObjectType:String) -> UIImage? {
        if self.isValid(contents) {
            return self.drawCompleteBarcode(self.completeBarcode(self.barcode(contents)))
        }
        return nil
    }
    
    public func generateCode(contents:String, machineReadableCodeObjectType:String) -> UIImage? {
        return self.generateCode(contents, inputCorrectionLevel: .Medium, machineReadableCodeObjectType: machineReadableCodeObjectType)
    }
    
    // Class funcs
    
    // Get CIFilter name by machine readable code object type
    public class func filterName(machineReadableCodeObjectType:String) -> String! {
        if machineReadableCodeObjectType == AVMetadataObjectTypeQRCode {
            return "CIQRCodeGenerator"
        } else if machineReadableCodeObjectType == AVMetadataObjectTypePDF417Code {
            return "CIPDF417BarcodeGenerator"
        } else if machineReadableCodeObjectType == AVMetadataObjectTypeAztecCode {
            return "CIAztecCodeGenerator"
        } else if machineReadableCodeObjectType == AVMetadataObjectTypeCode128Code {
            return "CICode128BarcodeGenerator"
        } else {
            return ""
        }
    }
    
    // Generate CI related code image
    public class func generateCode(contents:String, inputCorrectionLevel: InputCorrectionLevel, filterName:String) -> UIImage? {
        if filterName.length() > 0 {
            let filter = CIFilter(name: filterName)
            if let filter = filter {
                filter.setDefaults()
                let inputMessage = contents.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                filter.setValue(inputMessage, forKey: "inputMessage")
                filter.setValue(inputCorrectionLevel.rawValue, forKey: "inputCorrectionLevel")
                
                let outputImage = filter.outputImage
                let context = CIContext(options: nil)
                if let outputImage = outputImage {
                    let cgImage = context.createCGImage(outputImage, fromRect: outputImage.extent)
                    return UIImage(CGImage: cgImage, scale: 1, orientation: UIImageOrientation.Up)
                }
            }
        }
        return nil
    }
    
    public class func generateCode(contents:String, filterName:String) -> UIImage? {
        return self.generateCode(contents, inputCorrectionLevel: .Medium, filterName: filterName)
    }
    
    // Resize image
    public class func resizeImage(source:UIImage, scale:CGFloat) -> UIImage {
        let width = source.size.width * scale
        let height = source.size.height * scale
        
        UIGraphicsBeginImageContext(CGSizeMake(width, height))
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.None)
        source.drawInRect(CGRectMake(0, 0, width, height))
        let target = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return target
    }
    
    public class func resizeImage(source:UIImage, targetSize:CGSize, contentMode:UIViewContentMode) -> UIImage {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var width = targetSize.width
        var height = targetSize.height
        if (contentMode == UIViewContentMode.ScaleToFill) { // contents scaled to fill
            // Nothing to do
        } else if (contentMode == UIViewContentMode.ScaleAspectFill) { // contents scaled to fill with fixed aspect. some portion of content may be clipped.
            let targtLength  = (targetSize.height > targetSize.width)   ? targetSize.height  : targetSize.width
            let sourceLength = (source.size.height < source.size.width) ? source.size.height : source.size.width
            let fillScale = targtLength / sourceLength
            width = source.size.width * fillScale
            height = source.size.height * fillScale
            x = (targetSize.width  - width)  / 2.0
            y = (targetSize.height - height) / 2.0
        } else  { // contents scaled to fit with fixed aspect. remainder is transparent
            let targtLength  = (targetSize.height < targetSize.width)   ? targetSize.height  : targetSize.width
            let sourceLength = (source.size.height > source.size.width) ? source.size.height : source.size.width
            let fillScale = targtLength / sourceLength
            width = source.size.width * fillScale
            height = source.size.height * fillScale
            if (contentMode == UIViewContentMode.ScaleAspectFit
                || contentMode == UIViewContentMode.Redraw
                || contentMode == UIViewContentMode.Center) {
                x = (targetSize.width  - width)  / 2.0
                y = (targetSize.height - height) / 2.0
            } else if (contentMode == UIViewContentMode.Top) {
                x = (targetSize.width  - width)  / 2.0
                y = 0
            } else if (contentMode == UIViewContentMode.Bottom) {
                x = (targetSize.width  - width)  / 2.0
                y = targetSize.height - height
            } else if (contentMode == UIViewContentMode.Left) {
                x = 0
                y = (targetSize.height - height) / 2.0
            } else if (contentMode == UIViewContentMode.Right) {
                x = targetSize.width  - width
                y = (targetSize.height - height) / 2.0
            } else if (contentMode == UIViewContentMode.TopLeft) {
                x = 0
                y = 0
            } else if (contentMode == UIViewContentMode.TopRight) {
                x = targetSize.width  - width
                y = 0
            } else if (contentMode == UIViewContentMode.BottomLeft) {
                x = 0
                y = targetSize.height - height
            } else if (contentMode == UIViewContentMode.BottomRight) {
                x = targetSize.width  - width
                y = targetSize.height - height
            }
        }

        UIGraphicsBeginImageContext(targetSize)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.None)
        source.drawInRect(CGRectMake(x, y, width, height))
        let target = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return target
    }
}