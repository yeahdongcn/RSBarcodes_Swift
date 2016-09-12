//
//  RSUnifiedCodeValidator.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 10/3/16.
//  Copyright (c) 2016 P.D.Q. All rights reserved.
//

import Foundation
import AVFoundation

open class RSUnifiedCodeValidator {
    open class var shared: RSUnifiedCodeValidator {
        return UnifiedCodeValidatorSharedInstance
    }
    
    open func isValid(_ contents:String, machineReadableCodeObjectType: String) -> Bool {
        var codeGenerator: RSCodeGenerator?
        switch machineReadableCodeObjectType {
        case AVMetadataObjectTypeQRCode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeAztecCode:
            return false
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
        case AVMetadataObjectTypeCode128Code:
            codeGenerator = RSCode128Generator()
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
            return false
        }
        return codeGenerator!.isValid(contents)
    }
}
let UnifiedCodeValidatorSharedInstance = RSUnifiedCodeValidator()
