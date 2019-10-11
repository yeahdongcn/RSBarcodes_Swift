//
//  ContextMaker.swift
//  RSBarcodes
//
//  Created by Alexey Korolev on 11.10.2019.
//  Copyright © 2019 P.D.Q. All rights reserved.
//

import UIKit

final class ContextMaker {
    static func make() -> CIContext {
        return CIContext(options: nil)
    }
}
