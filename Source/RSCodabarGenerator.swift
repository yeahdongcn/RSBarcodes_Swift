//
//  RSCodabarGenerator.swift
//  RSBarcodes
//
//  Created by 山崎謙登 on 2022/11/14.
//  Copyright © 2022 P.D.Q. All rights reserved.
//

import Foundation

private let CODABAR_ALPHABET_STRING = "0123456789-$:/.+ABCD"

/// https://www.keyence.com/ss/products/auto_id/codereader/basic/code39.jsp
/// https://en.wikipedia.org/wiki/Codabar
@available(macCatalyst 14.0, *)
open class RSCodaBarGenerator: RSAbstractCodeGenerator {
    private let CODABAR_CHARACTER_ENCODINGS = [
        "1010100110",  // 0
        "1010110010",  // 1
        "1010010110",  // 2
        "1100101010",  // 3
        "1011010010",  // 4
        "1101010010",  // 5
        "1001010110",  // 6
        "1001011010",  // 7
        "1001101010",  // 8
        "1101001010",  // 9
        "1010011010",  // ー
        "1011001010",  // $
        "11010110110", // :
        "11011010110", // /
        "11011011010", // .
        "10110110110", // +
        "10110010010", // A
        "10010010110", // B
        "10100100110", // C
        "10100110010"  // D
    ]
    
    
    /// Convenient method to get encoded representation of a parameter character
    /// - Parameter characterString: A character String
    /// - Returns: Encoded representation of a parameter characterString
    private func encodeCharacterString(_ characterString:String) -> String {
        let location = CODABAR_ALPHABET_STRING.location(characterString)
        return CODABAR_CHARACTER_ENCODINGS[location]
    }
        
    // MARK: RSAbstractCodeGenerator
    
    override open func isValid(_ contents: String) -> Bool {
        // Contents length is greater than 0 and
        // Contents do not include start and stop characters
        guard contents.length() > 0 else { return false }
        for character in contents {
            let location = CODABAR_ALPHABET_STRING.location(String(character))
            if location == NSNotFound {
                // Contents include any character that is not allowed as CODABAR
                return false
            }
        }
        return true
    }
    
    override open func barcode(_ contents: String) -> String {
        var barcode = ""
        for character in contents {
            barcode += self.encodeCharacterString(String(character))
        }
        return barcode
    }
}

