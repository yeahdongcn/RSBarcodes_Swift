//
//  RSCode39Generator.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/10/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import Foundation

let CODE39_ALPHABET_STRING = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%*"

// http://www.barcodesymbols.com/code39.htm
// http://www.barcodeisland.com/code39.phtml
public class RSCode39Generator: RSAbstractCodeGenerator {
    let CODE39_CHARACTER_ENCODINGS = [
        "1010011011010",
        "1101001010110",
        "1011001010110",
        "1101100101010",
        "1010011010110",
        "1101001101010",
        "1011001101010",
        "1010010110110",
        "1101001011010",
        "1011001011010",
        "1101010010110",
        "1011010010110",
        "1101101001010",
        "1010110010110",
        "1101011001010",
        "1011011001010",
        "1010100110110",
        "1101010011010",
        "1011010011010",
        "1010110011010",
        "1101010100110",
        "1011010100110",
        "1101101010010",
        "1010110100110",
        "1101011010010",
        "1011011010010",
        "1010101100110",
        "1101010110010",
        "1011010110010",
        "1010110110010",
        "1100101010110",
        "1001101010110",
        "1100110101010",
        "1001011010110",
        "1100101101010",
        "1001101101010",
        "1001010110110",
        "1100101011010",
        "1001101011010",
        "1001001001010",
        "1001001010010",
        "1001010010010",
        "1010010010010",
        "1001011011010"
    ]
    
    func encodeCharacterString(characterString:String) -> String {
        let location = CODE39_ALPHABET_STRING.location(characterString)
        return CODE39_CHARACTER_ENCODINGS[location]
    }
    
    // MAKR: RSAbstractCodeGenerator
    
    override public func isValid(contents: String) -> Bool {
        let length = contents.length()
        if length > 0 && contents == contents.uppercaseString {
            for character in contents.characters {
                let location = CODE39_ALPHABET_STRING.location(String(character))
                if location == NSNotFound {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    override public func initiator() -> String {
        return self.encodeCharacterString("*")
    }
    
    override public func terminator() -> String {
        return self.encodeCharacterString("*")
    }
    
    override public func barcode(contents: String) -> String {
        var barcode = ""
        for character in contents.characters {
            barcode += self.encodeCharacterString(String(character))
        }
        return barcode
    }
}