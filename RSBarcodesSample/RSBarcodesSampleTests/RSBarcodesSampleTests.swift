//
//  RSBarcodesSampleTests.swift
//  RSBarcodesSampleTests
//
//  Created by R0CKSTAR on 6/10/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import XCTest
import RSBarcodes

class RSBarcodesSampleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let g = RSUnifiedCodeGenerator.shared
        
        let c39r = g.generateCode("2166529V", machineReadableCodeObjectType: AVMetadataObjectTypeCode39Code)
        XCTAssert(c39r != nil, "Pass code 39")
        
        let c39m43r = g.generateCode("CODE 39", machineReadableCodeObjectType: AVMetadataObjectTypeCode39Mod43Code)
        XCTAssert(c39m43r != nil, "Pass code 39 mod 43")
        
        let ce39r = g.generateCode("R0ckStar", machineReadableCodeObjectType: RSBarcodesTypeExtendedCode39Code)
        XCTAssert(ce39r != nil, "Pass extended code 39")
        
        let ean8r = g.generateCode("47112346", machineReadableCodeObjectType: AVMetadataObjectTypeEAN8Code)
        XCTAssert(ean8r != nil, "Pass EAN8")
        
        let ean13r = g.generateCode("6902890884910", machineReadableCodeObjectType: AVMetadataObjectTypeEAN13Code)
        XCTAssert(ean13r != nil, "Pass EAN13")
        
        let isbn13r = g.generateCode("9789504200857", machineReadableCodeObjectType: RSBarcodesTypeISBN13Code)
        XCTAssert(isbn13r != nil, "Pass ISBN13")
        
        let issn13r = g.generateCode("9771234567003", machineReadableCodeObjectType: RSBarcodesTypeISSN13Code)
        XCTAssert(issn13r != nil, "Pass ISSN13")
        
        let itfr = g.generateCode("1234", machineReadableCodeObjectType: AVMetadataObjectTypeInterleaved2of5Code)
        XCTAssert(itfr != nil, "Pass ITF")
        
        let itf14r = g.generateCode("15400141288763", machineReadableCodeObjectType: AVMetadataObjectTypeITF14Code)
        XCTAssert(itf14r != nil, "Pass ITF14")
        
        let upcer = g.generateCode("04252614", machineReadableCodeObjectType: AVMetadataObjectTypeUPCECode)
        XCTAssert(upcer != nil, "Pass UPCE")
        
        let c93r = g.generateCode("TEST93", machineReadableCodeObjectType: AVMetadataObjectTypeCode93Code)
        XCTAssert(c93r != nil, "Pass code 93")
        
        g.isBuiltInCode128GeneratorSelected = true
        let c128r = g.generateCode("123456", machineReadableCodeObjectType: AVMetadataObjectTypeCode128Code)
        XCTAssert(c128r != nil, "Pass code 128 auto table")
        
        // Using custom code table for code 128.
        g.isBuiltInCode128GeneratorSelected = false
        let c128autor = RSCode128Generator().generateCode("123456", machineReadableCodeObjectType: AVMetadataObjectTypeCode128Code)
        XCTAssert(c128autor != nil, "Pass code 128 Auto table")
        
        let c128ar = RSCode128Generator(codeTable: .a).generateCode("123456", machineReadableCodeObjectType: AVMetadataObjectTypeCode128Code)
        XCTAssert(c128ar != nil, "Pass code 128 A table")
        
        let c128br = RSCode128Generator(codeTable: .b).generateCode("123456", machineReadableCodeObjectType: AVMetadataObjectTypeCode128Code)
        XCTAssert(c128br != nil, "Pass code 128 B table")
        
        let c128cr = RSCode128Generator(codeTable: .c).generateCode("123456", machineReadableCodeObjectType: AVMetadataObjectTypeCode128Code)
        XCTAssert(c128cr != nil, "Pass code 128 C table")

        let pdf417r = g.generateCode("123456", machineReadableCodeObjectType: AVMetadataObjectTypePDF417Code)
        XCTAssert(pdf417r != nil, "Pass PDF417")
        
        let qrr = g.generateCode("yeahdongcn", machineReadableCodeObjectType: AVMetadataObjectTypeQRCode)
        XCTAssert(qrr != nil, "Pass QR")
        
        let aztecr = g.generateCode("yeahdongcn", machineReadableCodeObjectType: AVMetadataObjectTypeAztecCode)
        XCTAssert(aztecr != nil, "Pass Aztec")
    }
    
    func testCICode128() {
        self.measure() {
            _ = RSUnifiedCodeGenerator.shared.generateCode("1234567890", machineReadableCodeObjectType: AVMetadataObjectTypeCode128Code)
        }
    }
    
    func testRSBarcodesCode128() {
        self.measure() {
            _ = RSCode128Generator().generateCode("1234567890", machineReadableCodeObjectType: AVMetadataObjectTypeCode128Code)
        }
    }
}
