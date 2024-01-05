//
//  RSUnifiedCodeValidator.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 10/3/16.
//  Copyright (c) 2016 P.D.Q. All rights reserved.
//

import Foundation
import AVFoundation

@available(macCatalyst 14.0, *)
open class RSUnifiedCodeValidator {
    open class var shared: RSUnifiedCodeValidator {
        return UnifiedCodeValidatorSharedInstance
    }
    
    open func isValid(_ contents:String, machineReadableCodeObjectType: String) -> Bool {
        var codeGenerator: RSCodeGenerator?
        switch machineReadableCodeObjectType {
        case AVMetadataObject.ObjectType.qr.rawValue, AVMetadataObject.ObjectType.pdf417.rawValue, AVMetadataObject.ObjectType.aztec.rawValue:
            return false
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
        case AVMetadataObject.ObjectType.code128.rawValue:
            codeGenerator = RSCode128Generator()
        case AVMetadataObject.ObjectType.dataMatrix.rawValue:
            codeGenerator = RSDataMatrixGenerator()
        case RSBarcodesTypeISBN13Code:
            codeGenerator = RSISBN13Generator()
        case RSBarcodesTypeISSN13Code:
            codeGenerator = RSISSN13Generator()
        case RSBarcodesTypeExtendedCode39Code:
            codeGenerator = RSExtendedCode39Generator()
        default:
            if #available(iOS 15.4, *), machineReadableCodeObjectType == AVMetadataObject.ObjectType.codabar.rawValue {
                codeGenerator = RSCodaBarGenerator()
            }
            else {
                print("No code generator selected.")
                return false
            }
        }
        return codeGenerator!.isValid(contents)
    }
}

@available(macCatalyst 14.0, *)
let UnifiedCodeValidatorSharedInstance = RSUnifiedCodeValidator()
