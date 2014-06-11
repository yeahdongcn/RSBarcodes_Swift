//
//  RSEANGenerator.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/11/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit

let RSMetadataObjectTypeISBN13Code = "com.pdq.rsbarcodes.isbn13"
let RSMetadataObjectTypeISSN13Code = "com.pdq.rsbarcodes.issn13"

// http://blog.sina.com.cn/s/blog_4015406e0100bsqk.html
class RSEANGenerator: RSAbstractCodeGenerator {
    init(length:Int) {
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
    override func isValid(contents: String) -> Bool {
        // http://www.appsbarcode.com/ISBN.php
        return super.isValid(contents) && contents.substring(0, length: 3) == "978"
    }
}

class RSISSN13Generator: RSEAN13Generator {
    override func isValid(contents: String) -> Bool {
        // http://www.appsbarcode.com/ISSN.php
        return super.isValid(contents) && contents.substring(0, length: 3) == "977"
    }
}