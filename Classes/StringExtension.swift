//
//  Ext.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/10/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit

extension String {
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
    }
    
    func substring(start: Int, length: Int = 1) -> String {
        var i = 0
        var range = ""
        let end = start + length
        
        if end < start || start < 0 || length < 1 {
            return range
        }
        
        for char in self {
            if i >= start && i < end {
                range += char
            }
            if i >= end {
                break
            }
            i++
        }
        return range
    }
    
    subscript(index: Int) -> String? {
        get {
            return self.substring(index, length: 1)
        }
    }
    
    func contains(other: String) -> Bool{
        var start = startIndex
        do {
            var subString = self[Range(start: start++, end: endIndex)]
            if subString.hasPrefix(other){
                return true
            }
        } while start != endIndex
        return false
    }
}