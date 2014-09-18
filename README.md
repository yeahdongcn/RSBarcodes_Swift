<p align="center">
  <img src="https://raw.githubusercontent.com/yeahdongcn/RSBarcodes_Swift/master/home-hero-swift-hero.png">
</p>

RSBarcodes, now Swift.
==========
[![Total views](https://sourcegraph.com/api/repos/github.com/yeahdongcn/RSBarcodes_Swift/counters/views.png)](https://sourcegraph.com/github.com/yeahdongcn/RSBarcodes_Swift)
[![Views in the last 24 hours](https://sourcegraph.com/api/repos/github.com/yeahdongcn/RSBarcodes_Swift/counters/views-24h.png)](https://sourcegraph.com/github.com/yeahdongcn/RSBarcodes_Swift)

RSBarcodes allows you to read 1D and 2D barcodes using metadata scanning capabilities introduced with iOS 7 and generate the same set of barcode images for displaying and sharing. Now Swift.

* Objc version. [RSBarcodes](https://github.com/yeahdongcn/RSBarcodes)

##TODO

###Generators
* ~~Code39~~
* ~~Code39Mod43~~
* ~~ExtendedCode39~~
* ~~Code93~~
* ~~Code128~~
* ~~UPCE~~
* ~~EAN FAMILIY (EAN8 EAN13 ISBN13 ISSN13)~~
* ~~ITF14~~
* ~~Interleaved2of5~~
* DataMatrix
* ~~PDF417~~
* ~~QR~~
* ~~Aztec~~
* ~~Views~~

###Reader
* ~~Views~~
* ~~ReaderController~~

##Installation

~~[CocoaPods](http://cocoapods.org/) is the recommended method of installing RSBarcodes_Swift.~~

~~Simply add the following line to your `Podfile`:~~

    pod 'RSBarcodes_Swift', '~> 0.0.2'

For now, directly add `*.swift` under `Classes` folder into the project created using Swift language.

##Usage

###Generators

The simplest way to use the generators is:

    RSUnifiedCodeGenerator.shared.generateCode("2166529V", machineReadableCodeObjectType: AVMetadataObjectTypeCode39Code)

It will generate an UIImage instance if the `2166529V` is a valid code39 string. For AVMetadataObjectTypeCode128Code, you can change `useBuiltInCode128Generator` to `false` to use my implementation (AutoTable for code128).

P.S. There are 4 table for encoding a string to code128, `TableA`, `TableB`, `TableC` and `TableAuto`, the `TableAuto` is always the best choice, but if one has certain requirement, try this:

    RSCode128Generator(codeTable: .A).generateCode("123456", machineReadableCodeObjectType: AVMetadataObjectTypeCode128Code)

These calling simples can be found in the test project.

###Reader

Place an `UIViewController` in storyboard and set `RSCodeReaderViewController` based class as its custom class and it almost there, focus mark layer and corners layer is already there working for you. There are to handlers, one for the single tap on the screen along with the focus mark and the other is detected objects handler, which all detected will come to you. Set them up in `viewDidLoad()` or some place more suitable:

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.focusMarkLayer.strokeColor = UIColor.redColor().CGColor
        
        self.cornersLayer.strokeColor = UIColor.yellowColor().CGColor
        
        self.tapHandler = { point in
            println(point)
        }
        
        self.barcodesHandler = { barcodes in
            for barcode in barcodes {
                println(barcode)
            }
        }
    }

##Miscellaneous

[The Swift Programming Language 中文版](https://github.com/numbbbbb/the-swift-programming-language-in-chinese/)

[Online version](http://numbbbbb.github.io/the-swift-programming-language-in-chinese/) generated using [GitBook](https://www.gitbook.io/)

##License

    The MIT License (MIT)

    Copyright (c) 2012-2014 P.D.Q.

    Permission is hereby granted, free of charge, to any person obtaining a copy of
    this software and associated documentation files (the "Software"), to deal in
    the Software without restriction, including without limitation the rights to
    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
    the Software, and to permit persons to whom the Software is furnished to do so,
    subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
    COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
    CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
