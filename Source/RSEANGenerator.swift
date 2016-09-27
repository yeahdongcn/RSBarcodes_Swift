//
//  RSEANGenerator.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/11/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit

public let RSBarcodesTypeISBN13Code = "com.pdq.rsbarcodes.isbn13"
public let RSBarcodesTypeISSN13Code = "com.pdq.rsbarcodes.issn13"

// http://blog.sina.com.cn/s/blog_4015406e0100bsqk.html
open class RSEANGenerator: RSAbstractCodeGenerator {
    var length = 0
    // 'O' for odd and 'E' for even
    let lefthandParities = [
        "OOOOOO",
        "OOEOEE",
        "OOEEOE",
        "OOEEEO",
        "OEOOEE",
        "OEEOOE",
        "OEEEOO",
        "OEOEOE",
        "OEOEEO",
        "OEEOEO"
    ]
    // 'R' for right-hand
    let parityEncodingTable = [
        ["O" : "0001101", "E" : "0100111", "R" : "1110010"],
        ["O" : "0011001", "E" : "0110011", "R" : "1100110"],
        ["O" : "0010011", "E" : "0011011", "R" : "1101100"],
        ["O" : "0111101", "E" : "0100001", "R" : "1000010"],
        ["O" : "0100011", "E" : "0011101", "R" : "1011100"],
        ["O" : "0110001", "E" : "0111001", "R" : "1001110"],
        ["O" : "0101111", "E" : "0000101", "R" : "1010000"],
        ["O" : "0111011", "E" : "0010001", "R" : "1000100"],
        ["O" : "0110111", "E" : "0001001", "R" : "1001000"],
        ["O" : "0001011", "E" : "0010111", "R" : "1110100"]
    ]
    
    init(length:Int) {
        self.length = length
    }
    
    override open func isValid(_ contents: String) -> Bool {
        if super.isValid(contents) && self.length == contents.length() {
            var sum_odd = 0
            var sum_even = 0
            
            for i in 0..<(self.length - 1) {
                let digit = Int(contents[i])!
                if i % 2 == (self.length == 13 ? 0 : 1) {
                    sum_even += digit
                } else {
                    sum_odd += digit
                }
            }
            let checkDigit = (10 - (sum_even + sum_odd * 3) % 10) % 10
            return Int(contents[contents.length() - 1]) == checkDigit
        }
        return false
    }
    
    override open func initiator() -> String {
        return "101"
    }
    
    override open func terminator() -> String {
        return "101"
    }
    
    func centerGuardPattern() -> String {
        return "01010"
    }
    
    override open func barcode(_ contents: String) -> String {
        var lefthandParity = "OOOO"
        var newContents = contents
        if self.length == 13 {
            lefthandParity = self.lefthandParities[Int(contents[0])!]
            newContents = contents.substring(1, length: contents.length() - 1)
        }
        
        var barcode = ""
        for i in 0..<newContents.length() {
            let digit = Int(newContents[i])!
            if i < lefthandParity.length() {
                barcode += self.parityEncodingTable[digit][lefthandParity[i]]!
                if i == lefthandParity.length() - 1 {
                    barcode += self.centerGuardPattern()
                }
            } else {
                barcode += self.parityEncodingTable[digit]["R"]!
            }
        }
        return barcode
    }
}

class RSEAN8Generator: RSEANGenerator {
    init() {
        super.init(length: 8)
    }
}

class RSEAN13Generator: RSEANGenerator {
    init() {
        super.init(length: 13)
    }
}

class RSISBN13Generator: RSEAN13Generator {
    override func isValid(_ contents: String) -> Bool {
        // http://www.appsbarcode.com/ISBN.php
        return super.isValid(contents) && contents.substring(0, length: 3) == "978"
    }
}

class RSISSN13Generator: RSEAN13Generator {
    override func isValid(_ contents: String) -> Bool {
        // http://www.appsbarcode.com/ISSN.php
        return super.isValid(contents) && contents.substring(0, length: 3) == "977"
    }
}
