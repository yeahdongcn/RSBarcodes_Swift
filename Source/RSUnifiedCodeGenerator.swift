//
//  RSUnifiedCodeGenerator.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/10/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

open class RSUnifiedCodeGenerator: RSCodeGenerator {
    
    open var isBuiltInCode128GeneratorSelected = false
    open var fillColor: UIColor = UIColor.white
    open var strokeColor: UIColor = UIColor.black
    
    open class var shared: RSUnifiedCodeGenerator {
        return UnifiedCodeGeneratorSharedInstance
    }
    
    // MARK: RSCodeGenerator
    
    open func isValid(_ contents: String) -> Bool {
        print("Use RSUnifiedCodeValidator.shared.isValid(contents:String, machineReadableCodeObjectType: String) instead")
        return false
    }
    
    open func generateCode(_ contents: String, inputCorrectionLevel: InputCorrectionLevel, machineReadableCodeObjectType: String, targetSize: CGSize? = nil) -> UIImage? {
        var codeGenerator: RSCodeGenerator?
        switch machineReadableCodeObjectType {
        case AVMetadataObject.ObjectType.qr.rawValue, AVMetadataObject.ObjectType.pdf417.rawValue, AVMetadataObject.ObjectType.aztec.rawValue:
            return RSAbstractCodeGenerator.generateCode(contents, inputCorrectionLevel: inputCorrectionLevel, filterName: RSAbstractCodeGenerator.filterName(machineReadableCodeObjectType), targetSize: targetSize, fillColor: fillColor, strokeColor: strokeColor)
        case AVMetadataObject.ObjectType.code39.rawValue:
            codeGenerator = RSCode39Generator()
        case AVMetadataObject.ObjectType.code39Mod43.rawValue:
            codeGenerator = RSCode39Mod43Generator()
        case AVMetadataObject.ObjectType.ean8.rawValue:
            codeGenerator = RSEAN8Generator()
        case AVMetadataObject.ObjectType.ean13.rawValue:
            codeGenerator = RSEAN13Generator()
        case AVMetadataObject.ObjectType.interleaved2of5.rawValue:
            codeGenerator = RSITFGenerator()
        case AVMetadataObject.ObjectType.itf14.rawValue:
            codeGenerator = RSITF14Generator()
        case AVMetadataObject.ObjectType.upce.rawValue:
            codeGenerator = RSUPCEGenerator()
        case AVMetadataObject.ObjectType.code93.rawValue:
            codeGenerator = RSCode93Generator()
            // iOS 8 included, but my implementation's performance is better :)
        case AVMetadataObject.ObjectType.code128.rawValue:
            if self.isBuiltInCode128GeneratorSelected {
                return RSAbstractCodeGenerator.generateCode(contents, inputCorrectionLevel: inputCorrectionLevel, filterName: RSAbstractCodeGenerator.filterName(machineReadableCodeObjectType), targetSize: targetSize, fillColor: fillColor, strokeColor: strokeColor)
            } else {
                codeGenerator = RSCode128Generator()
            }
        case AVMetadataObject.ObjectType.dataMatrix.rawValue:
            codeGenerator = RSCodeDataMatrixGenerator()
        case RSBarcodesTypeISBN13Code:
            codeGenerator = RSISBN13Generator()
        case RSBarcodesTypeISSN13Code:
            codeGenerator = RSISSN13Generator()
        case RSBarcodesTypeExtendedCode39Code:
            codeGenerator = RSExtendedCode39Generator()
        default:
            print("No code generator selected.")
        }
        
        if codeGenerator != nil {
            codeGenerator!.fillColor = self.fillColor
            codeGenerator!.strokeColor = self.strokeColor
            return codeGenerator!.generateCode(contents, inputCorrectionLevel: inputCorrectionLevel, machineReadableCodeObjectType: machineReadableCodeObjectType, targetSize: targetSize)
        } else {
            return nil
        }
    }
    
    open func generateCode(_ contents: String, machineReadableCodeObjectType: String, targetSize: CGSize? = nil) -> UIImage? {
        return self.generateCode(contents, inputCorrectionLevel: .Medium, machineReadableCodeObjectType: machineReadableCodeObjectType, targetSize: targetSize)
    }
    
    open func generateCode(_ machineReadableCodeObject: AVMetadataMachineReadableCodeObject, inputCorrectionLevel: InputCorrectionLevel, targetSize: CGSize? = nil) -> UIImage? {
        return self.generateCode(machineReadableCodeObject.stringValue!, inputCorrectionLevel: inputCorrectionLevel, machineReadableCodeObjectType: machineReadableCodeObject.type.rawValue, targetSize: targetSize)
    }
    
    open func generateCode(_ machineReadableCodeObject: AVMetadataMachineReadableCodeObject, targetSize: CGSize? = nil) -> UIImage? {
        return self.generateCode(machineReadableCodeObject, inputCorrectionLevel: .Medium, targetSize: targetSize)
    }
}

let UnifiedCodeGeneratorSharedInstance = RSUnifiedCodeGenerator()
