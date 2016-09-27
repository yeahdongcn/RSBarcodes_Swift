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
    
    open func generateCode(_ contents: String, inputCorrectionLevel: InputCorrectionLevel, machineReadableCodeObjectType: String) -> UIImage? {
        var codeGenerator: RSCodeGenerator?
        switch machineReadableCodeObjectType {
        case AVMetadataObjectTypeQRCode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeAztecCode:
            return RSAbstractCodeGenerator.generateCode(contents, inputCorrectionLevel: inputCorrectionLevel, filterName: RSAbstractCodeGenerator.filterName(machineReadableCodeObjectType))
        case AVMetadataObjectTypeCode39Code:
            codeGenerator = RSCode39Generator()
        case AVMetadataObjectTypeCode39Mod43Code:
            codeGenerator = RSCode39Mod43Generator()
        case AVMetadataObjectTypeEAN8Code:
            codeGenerator = RSEAN8Generator()
        case AVMetadataObjectTypeEAN13Code:
            codeGenerator = RSEAN13Generator()
        case AVMetadataObjectTypeInterleaved2of5Code:
            codeGenerator = RSITFGenerator()
        case AVMetadataObjectTypeITF14Code:
            codeGenerator = RSITF14Generator()
        case AVMetadataObjectTypeUPCECode:
            codeGenerator = RSUPCEGenerator()
        case AVMetadataObjectTypeCode93Code:
            codeGenerator = RSCode93Generator()
            // iOS 8 included, but my implementation's performance is better :)
        case AVMetadataObjectTypeCode128Code:
            if self.isBuiltInCode128GeneratorSelected {
                return RSAbstractCodeGenerator.generateCode(contents, inputCorrectionLevel: inputCorrectionLevel, filterName: RSAbstractCodeGenerator.filterName(machineReadableCodeObjectType))
            } else {
                codeGenerator = RSCode128Generator()
            }
        case AVMetadataObjectTypeDataMatrixCode:
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
            return codeGenerator!.generateCode(contents, inputCorrectionLevel: inputCorrectionLevel, machineReadableCodeObjectType: machineReadableCodeObjectType)
        } else {
            return nil
        }
    }
    
    open func generateCode(_ contents: String, machineReadableCodeObjectType: String) -> UIImage? {
        return self.generateCode(contents, inputCorrectionLevel: .Medium, machineReadableCodeObjectType: machineReadableCodeObjectType)
    }
    
    open func generateCode(_ machineReadableCodeObject: AVMetadataMachineReadableCodeObject, inputCorrectionLevel: InputCorrectionLevel) -> UIImage? {
        return self.generateCode(machineReadableCodeObject.stringValue, inputCorrectionLevel: inputCorrectionLevel, machineReadableCodeObjectType: machineReadableCodeObject.type)
    }
    
    open func generateCode(_ machineReadableCodeObject: AVMetadataMachineReadableCodeObject) -> UIImage? {
        return self.generateCode(machineReadableCodeObject, inputCorrectionLevel: .Medium)
    }
}

let UnifiedCodeGeneratorSharedInstance = RSUnifiedCodeGenerator()
