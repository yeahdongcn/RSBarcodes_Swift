//
//  RSITF14Generator.swift
//  RSBarcodesSample
//
//  Created by R0CKSTAR on 6/13/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//

import UIKit

// http://www.gs1au.org/assets/documents/info/user_manuals/barcode_technical_details/ITF_14_Barcode_Structure.pdf
// http://www.barcodeisland.com/int2of5.phtml
open class RSITF14Generator: RSITFGenerator {
    override open func isValid(_ contents: String) -> Bool {
        return super.isValid(contents) && contents.length() == 14
    }
}
