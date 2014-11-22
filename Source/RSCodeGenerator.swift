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

// Code generators are required to provide these two functions.
public protocol RSCodeGenerator {
     func generateCode(machineReadableCodeObject:AVMetadataMachineReadableCodeObject) -> UIImage?
    
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
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetShouldAntialias(context, false)
        
        UIColor.whiteColor().setFill()
        UIColor.blackColor().setStroke()
        
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
        CGContextDrawPath(context, kCGPathFillStroke)
        let barcode = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return barcode
    }
    
    // RSCodeGenerator
    
    public func generateCode(machineReadableCodeObject:AVMetadataMachineReadableCodeObject) -> UIImage? {
        return self.generateCode(machineReadableCodeObject.stringValue, machineReadableCodeObjectType: machineReadableCodeObject.type)
    }
    
    public func generateCode(contents:String, machineReadableCodeObjectType:String) -> UIImage? {
        if self.isValid(contents) {
            return self.drawCompleteBarcode(self.completeBarcode(self.barcode(contents)))
        }
        return nil
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
    public class func generateCode(contents:String, filterName:String) -> UIImage {
        if filterName == "" {
            return UIImage()
        }
        
        let filter = CIFilter(name: filterName)
        filter.setDefaults()
        let inputMessage = contents.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        filter.setValue(inputMessage, forKey: "inputMessage")
        
        let outputImage = filter.outputImage
        let context = CIContext(options: nil)
        let cgImage = context.createCGImage(outputImage, fromRect: outputImage.extent())
        return UIImage(CGImage: cgImage, scale: 1, orientation: UIImageOrientation.Up)!
    }
    
    // Resize image
    public class func resizeImage(source:UIImage, scale:CGFloat) -> UIImage {
        let width = source.size.width * scale
        let height = source.size.height * scale
        
        UIGraphicsBeginImageContext(CGSizeMake(width, height))
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, kCGInterpolationNone)
        source.drawInRect(CGRectMake(0, 0, width, height))
        let target = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return target
    }
}