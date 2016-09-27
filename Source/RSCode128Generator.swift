//
//  RSCode128Generator.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/11/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit

public enum RSCode128GeneratorCodeTable: Int {
    case auto = 0
    case a, b, c
}

// http://www.barcodeisland.com/code128.phtml
// http://courses.cs.washington.edu/courses/cse370/01au/minirproject/BarcodeBattlers/barcodes.html
open class RSCode128Generator: RSAbstractCodeGenerator, RSCheckDigitGenerator {
    class RSCode128GeneratorAutoCodeTable {
        var startCodeTable = RSCode128GeneratorCodeTable.auto
        var sequence:Array<Int> = []
    }
    
    var codeTable: RSCode128GeneratorCodeTable
    var codeTableSize: Int
    var autoCodeTable: RSCode128GeneratorAutoCodeTable
    
    public init(codeTable:RSCode128GeneratorCodeTable) {
        self.codeTable = codeTable
        self.codeTableSize = CODE128_CHARACTER_ENCODINGS.count
        self.autoCodeTable = RSCode128GeneratorAutoCodeTable()
    }
    
    public convenience override init() {
        self.init(codeTable: .auto)
    }
    
    func startCodeTableValue(_ startCodeTable: RSCode128GeneratorCodeTable) -> Int {
        switch self.autoCodeTable.startCodeTable {
        case .a:
            return self.codeTableSize - 4
        case .b:
            return self.codeTableSize - 3
        case .c:
            return self.codeTableSize - 2
        default:
            switch startCodeTable {
            case .a:
                return self.codeTableSize - 4
            case .b:
                return self.codeTableSize - 3
            case .c:
                return self.codeTableSize - 2
            default:
                return 0
            }
        }
    }
    
    func middleCodeTableValue(_ codeTable:RSCode128GeneratorCodeTable) -> Int {
        switch codeTable {
        case .a:
            return self.codeTableSize - 6
        case .b:
            return self.codeTableSize - 7
        case .c:
            return self.codeTableSize - 8
        default:
            return 0
        }
    }
    
    func calculateContinousDigits(_ contents:String, defaultCodeTable:RSCode128GeneratorCodeTable, range:Range<Int>) {
        var isFinished = false
        if range.upperBound == contents.length() {
            isFinished = true
        }
        
        let length = range.upperBound - range.lowerBound
        if (range.lowerBound == 0 && length >= 4)
            || (range.lowerBound > 0 && length >= 6) {
            var isOrphanDigitUsed = false
            // Use START C when continous digits are found from range.location == 0
            if range.lowerBound == 0 {
                self.autoCodeTable.startCodeTable = .c
            } else {
                if length % 2 == 1 {
                    let digitValue = CODE128_ALPHABET_STRING.location(contents[range.lowerBound])
                    self.autoCodeTable.sequence.append(digitValue)
                    isOrphanDigitUsed = true
                }
                self.autoCodeTable.sequence.append(self.middleCodeTableValue(.c))
            }
            
            // Insert all xx combinations
            for i in 0..<length / 2 {
                let startIndex = range.lowerBound + i * 2
                let digitValue = Int(contents.substring(isOrphanDigitUsed ? startIndex + 1 : startIndex, length: 2))!
                self.autoCodeTable.sequence.append(digitValue)
            }
            
            if (length % 2 == 1 && !isOrphanDigitUsed) || !isFinished {
                self.autoCodeTable.sequence.append(self.middleCodeTableValue(defaultCodeTable))
            }
            
            if length % 2 == 1 && !isOrphanDigitUsed {
                let digitValue = CODE128_ALPHABET_STRING.location(contents[range.upperBound - 1])
                self.autoCodeTable.sequence.append(digitValue)
            }
            
            if !isFinished {
                let characterValue = CODE128_ALPHABET_STRING.location(contents[range.upperBound])
                self.autoCodeTable.sequence.append(characterValue)
            }
        } else {
            for i in range.lowerBound...(isFinished ? range.upperBound - 1 : range.upperBound) {
                let characterValue = CODE128_ALPHABET_STRING.location(contents[i])
                self.autoCodeTable.sequence.append(characterValue)
            }
        }
    }
    
    func calculateAutoCodeTable(_ contents:String) {
        if self.codeTable == .auto {
            // Select the short code table A as default code table
            var defaultCodeTable: RSCode128GeneratorCodeTable = .a
            
            // Determine whether to use code table B
            if let CODE128_ALPHABET_STRING_A = CODE128_ALPHABET_STRING.substring(0, length: 64) {
                for i in 0..<contents.length() {
                    if CODE128_ALPHABET_STRING_A.location(contents[i]) == NSNotFound
                        && defaultCodeTable == .a {
                        defaultCodeTable = .b
                        break
                    }
                }
            }
            
            var continousDigitsStartIndex:Int = NSNotFound
            for i in 0..<contents.length() {
                var continousDigitsRange:Range<Int> = Range<Int>(0..<0)
                if let character = contents[i] {
                    if DIGITS_STRING.location(character) == NSNotFound {
                        // Non digit found
                        if continousDigitsStartIndex != NSNotFound {
                            continousDigitsRange = Range<Int>(continousDigitsStartIndex..<i)
                        } else {
                            let characterValue = CODE128_ALPHABET_STRING.location(character)
                            self.autoCodeTable.sequence.append(characterValue)
                        }
                    } else {
                        // Digit found
                        if continousDigitsStartIndex == NSNotFound {
                            continousDigitsStartIndex = i
                        }
                        if continousDigitsStartIndex != NSNotFound && i == contents.length() - 1 {
                            continousDigitsRange = Range<Int>(continousDigitsStartIndex..<(i + 1))
                        }
                    }
                    
                    if continousDigitsRange.upperBound - continousDigitsRange.lowerBound != 0 {
                        self.calculateContinousDigits(contents, defaultCodeTable: defaultCodeTable, range: continousDigitsRange)
                        continousDigitsStartIndex = NSNotFound
                    }
                }
            }
            
            if self.autoCodeTable.startCodeTable == .auto {
                self.autoCodeTable.startCodeTable = defaultCodeTable
            }
        }
    }
    
    func encodeCharacterString(_ characterString:String) -> String {
        return CODE128_CHARACTER_ENCODINGS[CODE128_ALPHABET_STRING.location(characterString)]
    }
    
    override open func initiator() -> String {
        switch self.codeTable {
        case .auto:
            return CODE128_CHARACTER_ENCODINGS[self.startCodeTableValue(self.autoCodeTable.startCodeTable)]
        default:
            return CODE128_CHARACTER_ENCODINGS[self.startCodeTableValue(self.codeTable)]
        }
    }
    
    override open func terminator() -> String {
        return CODE128_CHARACTER_ENCODINGS[self.codeTableSize - 1] + "11"
    }
    
    override open func isValid(_ contents: String) -> Bool {
        if contents.length() > 0 {
            for i in 0..<contents.length() {
                if CODE128_ALPHABET_STRING.location(contents[i]) == NSNotFound {
                    return false
                }
            }
            
            switch self.codeTable {
            case .auto:
                self.calculateAutoCodeTable(contents)
                fallthrough
            case .b:
                return true
            case .a:
                if let CODE128_ALPHABET_STRING_A = CODE128_ALPHABET_STRING.substring(0, length: 64) {
                    for i in 0..<contents.length() {
                        if CODE128_ALPHABET_STRING_A.location(contents[i]) == NSNotFound {
                            return false
                        }
                    }
                }
                return true
            case .c:
                if contents.length() % 2 == 0 && contents.isNumeric() {
                    return true
                }
                return false
            }
        }
        return false
    }
    
    override open func barcode(_ contents: String) -> String {
        var barcode = ""
        switch self.codeTable {
        case .auto:
            for i in 0..<self.autoCodeTable.sequence.count {
                barcode += CODE128_CHARACTER_ENCODINGS[self.autoCodeTable.sequence[i]]
            }
        case .a, .b:
            for i in 0..<contents.length() {
                barcode += self.encodeCharacterString(contents[i])
            }
        case .c:
            for i in 0..<contents.length() {
                if i % 2 == 1 {
                    continue
                } else {
                    let value = Int(contents.substring(i, length: 2))!
                    barcode += CODE128_CHARACTER_ENCODINGS[value]
                }
            }
        }
        
        barcode += self.checkDigit(contents)
        return barcode
    }
    
    // MARK: RSCheckDigitGenerator
    
    open func checkDigit(_ contents: String) -> String {
        var sum = 0
        switch self.codeTable {
        case .auto:
            sum += self.startCodeTableValue(self.autoCodeTable.startCodeTable)
            for i in 0..<self.autoCodeTable.sequence.count {
                sum += self.autoCodeTable.sequence[i] * (i + 1)
            }
        case .a:
            sum = -1 // START A = self.codeTableSize - 4 = START B - 1
            fallthrough
        case .b:
            sum += self.codeTableSize - 3 // START B
            for i in 0..<contents.length() {
                let characterValue = CODE128_ALPHABET_STRING.location(contents[i])
                sum += characterValue * (i + 1)
            }
        case .c:
            sum += self.codeTableSize - 2 // START C
            for i in 0..<contents.length() {
                if i % 2 == 1 {
                    continue
                } else {
                    let value = Int(contents.substring(i, length: 2))!
                    sum += value * (i / 2 + 1)
                }
            }
        }
        return CODE128_CHARACTER_ENCODINGS[sum % 103]
    }
    
    let CODE128_ALPHABET_STRING = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_'abcdefghijklmnopqrstuvwxyz{|}~"
    
    let CODE128_CHARACTER_ENCODINGS = [
        "11011001100",
        "11001101100",
        "11001100110",
        "10010011000",
        "10010001100",
        "10001001100",
        "10011001000",
        "10011000100",
        "10001100100",
        "11001001000",
        "11001000100",
        "11000100100",
        "10110011100",
        "10011011100",
        "10011001110",
        "10111001100",
        "10011101100",
        "10011100110",
        "11001110010",
        "11001011100",
        "11001001110",
        "11011100100",
        "11001110100",
        "11101101110",
        "11101001100",
        "11100101100",
        "11100100110",
        "11101100100",
        "11100110100",
        "11100110010",
        "11011011000",
        "11011000110",
        "11000110110",
        "10100011000",
        "10001011000",
        "10001000110",
        "10110001000",
        "10001101000",
        "10001100010",
        "11010001000",
        "11000101000",
        "11000100010",
        "10110111000",
        "10110001110",
        "10001101110",
        "10111011000",
        "10111000110",
        "10001110110",
        "11101110110",
        "11010001110",
        "11000101110",
        "11011101000",
        "11011100010",
        "11011101110",
        "11101011000",
        "11101000110",
        "11100010110",
        "11101101000",
        "11101100010",
        "11100011010",
        "11101111010",
        "11001000010",
        "11110001010",
        "10100110000", // 64
        // Visible character encoding for code table A ended.
        "10100001100",
        "10010110000",
        "10010000110",
        "10000101100",
        "10000100110",
        "10110010000",
        "10110000100",
        "10011010000",
        "10011000010",
        "10000110100",
        "10000110010",
        "11000010010",
        "11001010000",
        "11110111010",
        "11000010100",
        "10001111010",
        "10100111100",
        "10010111100",
        "10010011110",
        "10111100100",
        "10011110100",
        "10011110010",
        "11110100100",
        "11110010100",
        "11110010010",
        "11011011110",
        "11011110110",
        "11110110110",
        "10101111000",
        "10100011110",
        "10001011110",
        // Visible character encoding for code table B ended.
        "10111101000",
        "10111100010",
        "11110101000",
        "11110100010",
        "10111011110", // to C from A, B (size - 8)
        "10111101110", // to B from A, C (size - 7)
        "11101011110", // to A from B, C (size - 6)
        "11110101110",
        "11010000100", // START A (size - 4)
        "11010010000", // START B (size - 3)
        "11010011100", // START C (size - 2)
        "11000111010"  // STOP    (size - 1)
    ]
}
