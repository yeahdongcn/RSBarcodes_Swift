//
//  RSCode93Generator.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/11/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit

// http://www.barcodeisland.com/code93.phtml
open class RSCode93Generator: RSAbstractCodeGenerator, RSCheckDigitGenerator {
    let CODE93_ALPHABET_STRING    = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%abcd*"
    
    let CODE93_PLACEHOLDER_STRING = "abcd";

    let CODE93_CHARACTER_ENCODINGS = [
        "100010100",
        "101001000",
        "101000100",
        "101000010",
        "100101000",
        "100100100",
        "100100010",
        "101010000",
        "100010010",
        "100001010",
        "110101000",
        "110100100",
        "110100010",
        "110010100",
        "110010010",
        "110001010",
        "101101000",
        "101100100",
        "101100010",
        "100110100",
        "100011010",
        "101011000",
        "101001100",
        "101000110",
        "100101100",
        "100010110",
        "110110100",
        "110110010",
        "110101100",
        "110100110",
        "110010110",
        "110011010",
        "101101100",
        "101100110",
        "100110110",
        "100111010",
        "100101110",
        "111010100",
        "111010010",
        "111001010",
        "101101110",
        "101110110",
        "110101110",
        "100100110",
        "111011010",
        "111010110",
        "100110010",
        "101011110"
    ]
    
    
    func encodeCharacterString(_ characterString:String) -> String {
        return CODE93_CHARACTER_ENCODINGS[CODE93_ALPHABET_STRING.location(characterString)]
    }
    
    override open func isValid(_ contents: String) -> Bool {
        if contents.length() > 0 && contents == contents.uppercased() {
            for i in 0..<contents.length() {
                if CODE93_ALPHABET_STRING.location(contents[i]) == NSNotFound {
                    return false
                }
                if CODE93_PLACEHOLDER_STRING.location(contents[i]) != NSNotFound {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    override open func initiator() -> String {
        return self.encodeCharacterString("*")
    }
    
    override open func terminator() -> String {
        // With the termination bar: 1
        return self.encodeCharacterString("*") + "1"
    }
    
    override open func barcode(_ contents: String) -> String {
        var barcode = ""
        for character in contents.characters {
            barcode += self.encodeCharacterString(String(character))
        }
        
        let checkDigits = self.checkDigit(contents)
        for character in checkDigits.characters {
            barcode += self.encodeCharacterString(String(character))
        }
        return barcode
    }
    
    // MARK: RSCheckDigitGenerator
    
    open func checkDigit(_ contents: String) -> String {
        // Weighted sum += value * weight
        
        // The first character
        var sum = 0
        for i in 0..<contents.length() {
            if let character = contents[contents.length() - i - 1] {
                let characterValue = CODE93_ALPHABET_STRING.location(character)
                sum += characterValue * (i % 20 + 1)
            }
        }
        var checkDigits = ""
        checkDigits += CODE93_ALPHABET_STRING[sum % 47]
        
        // The second character
        sum = 0
        let newContents = contents + checkDigits
        for i in 0..<newContents.length() {
            if let character = newContents[newContents.length() - i - 1] {
                let characterValue = CODE93_ALPHABET_STRING.location(character)
                sum += characterValue * (i % 15 + 1)
            }
        }
        checkDigits += CODE93_ALPHABET_STRING[sum % 47]
        return checkDigits
    }
}
