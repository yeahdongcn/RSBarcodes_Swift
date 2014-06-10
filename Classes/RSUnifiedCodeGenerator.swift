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

class RSUnifiedCodeGenerator: RSCodeGenerator {
    
    class var sharedInstance: RSUnifiedCodeGenerator {
        return UnifiedCodeGeneratorSharedInstance
    }
    
    // RSCodeGenerator
    func generateCode(contents: String, machineReadableCodeObjectType: String) -> UIImage? {
        if machineReadableCodeObjectType == AVMetadataObjectTypeQRCode
            || machineReadableCodeObjectType == AVMetadataObjectTypeQRCode
            || machineReadableCodeObjectType == AVMetadataObjectTypeQRCode {
                return RSAbstractCodeGenerator.generateCode(contents, filterName: RSAbstractCodeGenerator.filterName(machineReadableCodeObjectType))
        }
        var codeGenerator:RSCodeGenerator? = nil
        if machineReadableCodeObjectType == AVMetadataObjectTypeCode39Code {
            
        }
        
        if (codeGenerator) {
            return codeGenerator!.generateCode(contents, machineReadableCodeObjectType: machineReadableCodeObjectType)
        } else {
            return nil
        }
    }
    
    func generateCode(machineReadableCodeObject: AVMetadataMachineReadableCodeObject) -> UIImage? {
        return self.generateCode(machineReadableCodeObject.stringValue, machineReadableCodeObjectType: machineReadableCodeObject.type)
    }
}

let UnifiedCodeGeneratorSharedInstance = RSUnifiedCodeGenerator()
