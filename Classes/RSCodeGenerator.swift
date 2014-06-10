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

let DIGITS_STRING = "0123456789"

// Code generators are required to provide these two functions.
protocol RSCodeGenerator {
    func generateCode(machineReadableCodeObject:AVMetadataMachineReadableCodeObject) -> UIImage?
    
    func generateCode(contents:String, machineReadableCodeObjectType:String) -> UIImage?
}

// Check digit are not required for all code generators.
// UPC-E is using check digit to valid the contents to be encoded.
// Code39Mod43, Code93 and Code128 is using check digit to encode barcode.
@objc protocol RSCheckDigitGenerator {
    @optional func checkDigit(contents:String) -> String
}

// Abstract code generator, provides default functions for validations and generations.
class RSAbstractCodeGenerator : RSCodeGenerator {
    
    // Check whether the given contents are valid.
    func isValid(contents:String) -> Bool {
        let length = contents.utf16count
        if length > 0 {
            for var i:Int = 0; i < length; i++ {
                var character = contents[i]
                if (!DIGITS_STRING.contains(character!)) {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    // Barcode initiator, subclass should return its own value.
    func initiator() -> String {
        return ""
    }
    
    // Barcode terminator, subclass should return its own value.
    func terminator() -> String {
        return ""
    }
    
    // Barcode content, subclass should return its own value.
    func barcode(contents:String) -> String {
        return ""
    }
    
    // Composer for combining barcode initiator, contents, terminator together.
    func completeBarcode(barcode:String) -> String {
        return self.initiator() + barcode + self.terminator()
    }
    
    // Drawer for completed barcode.
    func drawCompleteBarcode(completeBarcode:String) -> UIImage? {
        var length:Int = completeBarcode.utf16count
        if length <= 0 {
            return nil
        }
        
        // Values taken from CIImage generated AVMetadataObjectTypePDF417Code type image
        // Top spacing          = 1.5
        // Bottom spacing       = 2
        // Left & right spacing = 2
        // Height               = 28
        let width = length + 4
        var size = CGSizeMake(CGFloat(width), 28)
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        var context = UIGraphicsGetCurrentContext()
        
        CGContextSetShouldAntialias(context, false)
        
        UIColor.whiteColor().setFill()
        UIColor.blackColor().setStroke()
        
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height))
        CGContextSetLineWidth(context, 1)
        
        for var i:Int = 0; i < length; i++ {
            var character = completeBarcode[i]
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
    func generateCode(machineReadableCodeObject:AVMetadataMachineReadableCodeObject) -> UIImage? {
        return self.generateCode(machineReadableCodeObject.stringValue, machineReadableCodeObjectType: machineReadableCodeObject.type);
    }
    
    func generateCode(contents:String, machineReadableCodeObjectType:String) -> UIImage? {
        if self.isValid(contents) {
            return self.drawCompleteBarcode(self.completeBarcode(self.barcode(contents)));
        }
        return nil
    }
}

//
//static inline NSString* getFilterName(NSString *codeObjectType)
//{
//    if ([codeObjectType isEqualToString:AVMetadataObjectTypeQRCode]) {
//        return @"CIQRCodeGenerator";
//    } else if ([codeObjectType isEqualToString:AVMetadataObjectTypePDF417Code]) {
//        return @"CIPDF417BarcodeGenerator";
//    } else if ([codeObjectType isEqualToString:AVMetadataObjectTypeAztecCode]) {
//        return @"CIAztecCodeGenerator";
//    }
//    return nil;
//}
//
//static inline UIImage* genCode(NSString *contents, NSString *filterName)
//{
//    CIFilter *filter = [CIFilter filterWithName:filterName];
//    [filter setDefaults];
//    NSData *data = [contents dataUsingEncoding:NSUTF8StringEncoding];
//    [filter setValue:data forKey:@"inputMessage"];
//    
//    CIImage *outputImage = [filter outputImage];
//    CIContext *context = [CIContext contextWithOptions:nil];
//    CGImageRef cgImage = [context createCGImage:outputImage
//    fromRect:[outputImage extent]];
//    UIImage *image = [UIImage imageWithCGImage:cgImage
//    scale:1
//    orientation:UIImageOrientationUp];
//    CGImageRelease(cgImage);
//    return image;
//}
//
//static inline UIImage *resizeImage(UIImage *source,
//float scale)
//{
//    CGFloat width = source.size.width * scale;
//    CGFloat height = source.size.height * scale;
//    
//    UIGraphicsBeginImageContext(CGSizeMake(width, height));
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
//    [source drawInRect:CGRectMake(0, 0, width, height)];
//    UIImage *target = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return target;
//}