//
//  RSCode128Generator.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/11/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit



// http://www.barcodeisland.com/code128.phtml
// http://courses.cs.washington.edu/courses/cse370/01au/minirproject/BarcodeBattlers/barcodes.html
class RSCode128Generator: RSAbstractCodeGenerator, RSCheckDigitGenerator {
    enum RSCode128GeneratorCodeTable: Int {
        case Auto = 0
        case A, B, C
    }
    

    class RSCode128GeneratorAutoCodeTable {
        var startCodeTable = RSCode128GeneratorCodeTable.Auto
        var sequence = []
    }
    
    
    
    var codeTable: RSCode128GeneratorCodeTable
    var codeTableSize: Int
    var autoCodeTable: RSCode128GeneratorAutoCodeTable
    
    init(contents:String, codeTable:RSCode128GeneratorCodeTable) {
        self.codeTable = codeTable
        self.codeTableSize = CODE128_CHARACTER_ENCODINGS.count
        self.autoCodeTable = RSCode128GeneratorAutoCodeTable()
    }
    
    convenience init(contents:String) {
        self.init(contents: contents, codeTable: RSCode128GeneratorCodeTable.Auto)
    }
    
    func startCodeTableValue(startCodeTable: RSCode128GeneratorCodeTable) -> Int {
        var codeTableValue = 0
        switch self.autoCodeTable.startCodeTable {
        case .A:
            return self.codeTableSize - 4
        case .B:
            return self.codeTableSize - 3
        case .C:
            return self.codeTableSize - 2
        default:
            return 0
        }
    }
    
    func encodeCharacterString(characterString:String) -> String {
        return CODE128_CHARACTER_ENCODINGS[CODE128_ALPHABET_STRING.location(characterString)]
    }
    
    override func initiator() -> String {
        switch self.codeTable {
        case .Auto:
            return CODE128_CHARACTER_ENCODINGS[self.startCodeTableValue(self.autoCodeTable.startCodeTable)]
        default:
            return CODE128_CHARACTER_ENCODINGS[self.startCodeTableValue(self.codeTable)]
        }
    }
    
    override func terminator() -> String {
        return CODE128_CHARACTER_ENCODINGS[self.codeTableSize - 1] + "11"
    }
    
    // RSCheckDigitGenerator
    
    func checkDigit(contents: String) -> String {
        return ""
    }
    
    let CODE128_ALPHABET_STRING = " !\"#$%&'()*+,-./0123456789:;<=>?ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_'abcdefghijklmnopqrstuvwxyz{|}~"
    
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
