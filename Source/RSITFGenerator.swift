//
//  RSITFGenerator.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/11/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit

// http://www.barcodeisland.com/int2of5.phtml
open class RSITFGenerator: RSAbstractCodeGenerator {
    let ITF_CHARACTER_ENCODINGS = [
        "00110",
        "10001",
        "01001",
        "11000",
        "00101",
        "10100",
        "01100",
        "00011",
        "10010",
        "01010",
        ]
    
    override open func isValid(_ contents: String) -> Bool {
        return super.isValid(contents) && contents.length() % 2 == 0
    }
    
    override open func initiator() -> String {
        return "1010"
    }
    
    override open func terminator() -> String {
        return "1101"
    }
    
    override open func barcode(_ contents: String) -> String {
        var barcode = ""
        for i in 0..<contents.length() / 2 {
            if let pair = contents.substring(i * 2, length: 2) {
                let bars = ITF_CHARACTER_ENCODINGS[Int(pair[0])!]
                let spaces = ITF_CHARACTER_ENCODINGS[Int(pair[1])!]
                
                for j in 0..<10 {
                    if j % 2 == 0 {
                        let bar = Int(bars[j / 2])
                        if bar == 1 {
                            barcode += "11"
                        } else {
                            barcode += "1"
                        }
                    } else {
                        let space = Int(spaces[j / 2])
                        if space == 1 {
                            barcode += "00"
                        } else {
                            barcode += "0"
                        }
                    }
                }
            }
        }
        return barcode
    }
}
