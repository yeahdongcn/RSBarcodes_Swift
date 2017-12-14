//
//  RSExtendedCode39Generator.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/11/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit

public let RSBarcodesTypeExtendedCode39Code = "com.pdq.rsbarcodes.code39.ext"

// http://www.barcodesymbols.com/code39.htm
// http://www.barcodeisland.com/code39.phtml
open class RSExtendedCode39Generator: RSCode39Generator {
    func encodeContents(_ contents: String) -> String {
        var encodedContents = ""
        for character in contents {
            let characterString = String(character)
            switch characterString {
            case "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z":
                encodedContents += "+" + characterString.uppercased()
            case "!":
                encodedContents += "/A"
            case "\"":
                encodedContents += "/B"
            case "#":
                encodedContents += "/C"
            case "$":
                encodedContents += "/D"
            case "%":
                encodedContents += "/E"
            case "&":
                encodedContents += "/F"
            case "'":
                encodedContents += "/G"
            case "(":
                encodedContents += "/H"
            case ")":
                encodedContents += "/I"
            case "*":
                encodedContents += "/J"
            case "+":
                encodedContents += "/K"
            case ",":
                encodedContents += "/L"
                // -   ->   /M   better to use -
                // .   ->   /N   better to use .
            case "/":
                encodedContents += "/O"
                // 0   ->   /P   better to use 0
                // 1   ->   /Q   better to use 1
                // 2   ->   /R   better to use 2
                // 3   ->   /S   better to use 3
                // 4   ->   /T   better to use 4
                // 5   ->   /U   better to use 5
                // 6   ->   /V   better to use 6
                // 7   ->   /W   better to use 7
                // 8   ->   /X   better to use 8
                // 9   ->   /Y   better to use 9
            case ":":
                encodedContents += "/Z"
                // ESC ->   %A
                // FS  ->   %B
                // GS  ->   %C
                // RS  ->   %D
                // US  ->   %E
            case ";":
                encodedContents += "%F"
            case "<":
                encodedContents += "%G"
            case "=":
                encodedContents += "%H"
            case ">":
                encodedContents += "%I"
            case "?":
                encodedContents += "%J"
            case "[":
                encodedContents += "%K"
            case "\\":
                encodedContents += "%L"
            case "]":
                encodedContents += "%M"
            case "^":
                encodedContents += "%N"
            case "_":
                encodedContents += "%O"
            case "{":
                encodedContents += "%P"
            case "|":
                encodedContents += "%Q"
            case "}":
                encodedContents += "%R"
            case "~":
                encodedContents += "%S"
                // DEL   ->   %T
                // NUL   ->   %U
            case "@":
                encodedContents += "%V"
            case "`":
                encodedContents += "%W"
                // SOH   ->   $A
                // STX   ->   $B
                // ETX   ->   $C
                // EOT   ->   $D
                // ENQ   ->   $E
                // ACK   ->   $F
                // BEL   ->   $G
                // BS    ->   $H
            case "\t":
                encodedContents += "$I"
                // LF    ->   $J
                // VT    ->   $K
                // FF    ->   $L
            case "\n":
                encodedContents += "$M"
                // SO    ->   $N
                // SI    ->   $O
                // DLE   ->   $P
                // DC1   ->   $Q
                // DC2   ->   $R
                // DC3   ->   $S
                // DC4   ->   $T
                // NAK   ->   $U
                // SYN   ->   $V
                // ETB   ->   $W
                // CAN   ->   $X
                // EM    ->   $Y
                // SUB   ->   $Z
            default:
                encodedContents += characterString
            }
        }
        return encodedContents
    }
    
    override open func isValid(_ contents: String) -> Bool {
        if contents.length() > 0 {
            let encContents = self.encodeContents(contents)
            for character in encContents {
                let location = CODE39_ALPHABET_STRING.location(String(character))
                if location == NSNotFound {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    override open func barcode(_ contents: String) -> String {
        return super.barcode(self.encodeContents(contents))
    }
}
