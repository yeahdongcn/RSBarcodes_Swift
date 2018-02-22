//
//  RSCode39Mod43Generator.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/10/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit

// http://www.barcodesymbols.com/code39.htm
// http://www.barcodeisland.com/code39.phtml
open class RSCode39Mod43Generator: RSCode39Generator, RSCheckDigitGenerator {
    
    // MARK: RSAbstractCodeGenerator
    
    override open func barcode(_ contents: String) -> String {
        return super.barcode(contents + self.checkDigit(contents.uppercased()))
    }
    
    // MARK: RSCheckDigitGenerator
    
    open func checkDigit(_ contents: String) -> String {
        /**
        Step 1: From the table below, find the values of each character.
        C    O    D    E        3    9    <--Message characters
        12   24   13   14  38   3    9    <--Character values
        
        Step 2: Sum the character values.
        12 + 24 + 13 + 14 + 38 + 3 + 9 = 113
        
        Step 3: Divide the result by 43.
        113 / 43 = 11  with remainder of 27.
        
        Step 4: From the table, find the character with this value.
        27 = R = Check Character
        */
        var sum = 0
        for character in contents {
            sum += CODE39_ALPHABET_STRING.location(String(character))
        }
        // 43 = CODE39_ALPHABET_STRING's length - 1 -- excludes asterisk
        return CODE39_ALPHABET_STRING[sum % (CODE39_ALPHABET_STRING.length() - 1)]
    }
}
