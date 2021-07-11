<p align="center">
  <img src="https://raw.githubusercontent.com/yeahdongcn/RSBarcodes_Swift/master/home-hero-swift-hero.png">
</p>

RSBarcodes, now in Swift.

[![Build Status](https://travis-ci.org/yeahdongcn/RSBarcodes_Swift.svg?branch=master)](https://travis-ci.org/yeahdongcn/RSBarcodes_Swift) [![codecov.io](https://codecov.io/gh/yeahdongcn/RSBarcodes_Swift/branch/master/graphs/badge.svg)](https://codecov.io/gh/yeahdongcn/RSBarcodes_Swift/branch/master) ![](https://img.shields.io/badge/Swift-5.0-blue.svg?style=flat) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) ![](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)

---

RSBarcodes allows you to read 1D and 2D barcodes using the metadata scanning capabilities introduced with iOS 7 and generate the same set of barcode images for displaying and sharing. Now implemented in Swift.

- Objective-C version: [RSBarcodes](https://github.com/yeahdongcn/RSBarcodes)

## TODO

### Generators

- [x] Code39
- [x] Code39Mod43
- [x] ExtendedCode39
- [x] Code93
- [x] Code128
- [x] UPCE
- [x] EAN FAMILIY (EAN8 EAN13 ISBN13 ISSN13)
- [x] ITF14
- [x] Interleaved2of5
- [ ] DataMatrix
- [x] PDF417
- [x] QR
- [x] Aztec
- [x] Views

### Reader

- [x] Views
- [x] ReaderController

## Installation

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

To add a package dependency to your Xcode project, select File > Swift Packages > Add Package Dependency and enter https://github.com/yeahdongcn/RSBarcodes_Swift to the text field.


### [CocoaPods](http://cocoapods.org)

Simply add the following lines to your `Podfile`:

```ruby
# required by Cocoapods 0.36.0.rc.1 for Swift Pods
use_frameworks!

pod 'RSBarcodes_Swift', '~> 5.1.1'
```

You will need to import RSBarcodes_Swift manually in the ViewController file after creating the file using wizard.

*(CocoaPods v0.36 or later required. See [this blog post](http://blog.cocoapods.org/Pod-Authors-Guide-to-CocoaPods-Frameworks/) for details.)*

### [Carthage](http://github.com/Carthage/Carthage)

Simply add the following line to your `Cartfile`:

```ruby
github "yeahdongcn/RSBarcodes_Swift" >= 5.1.1
```

You will need to import RSBarcodes_Swift manually in the ViewController file after creating the file using wizard.

### Swift Package Manager (required Xcode 11)

1. Select File > Swift Packages > Add Package Dependency. Enter `https://github.com/yeahdongcn/RSBarcodes_Swift` in the "Choose Package Repository" dialog.
2. In the next page, specify the version resolving rule as "Up to Next Major" with the latest version.
3. After Xcode checking out the source and resolving the version, you can choose the "RSBarcodes_Swift" library and add it to your app target.

### Manual

1. Add RSBarcodes_Swift as a [submodule](http://git-scm.com/docs/git-submodule) by opening the Terminal, `cd`-ing into your top-level project directory, and entering the command `git submodule add https://github.com/yeahdongcn/RSBarcodes_Swift.git`
2. Open the `RSBarcodes_Swift` folder, and drag `RSBarcodes.xcodeproj` into the file navigator of your app project.
3. In Xcode, navigate to the target configuration window by clicking on the blue project icon, and select the application target under the "Targets" heading in the sidebar.
4. Ensure that the deployment target of RSBarcodes.framework matches that of the application target.
5. In the tab bar at the top of that window, open the "Build Phases" panel.
6. Expand the "Target Dependencies" group, and add `RSBarcodes.framework`.
7. Click on the `+` button at the top left of the panel and select "New Copy Files Phase". Rename this new phase to "Copy Frameworks", set the "Destination" to "Frameworks", and add `RSBarcodes.framework`.
8. Need to import RSBarcodes manually in the ViewController file after creating the file using wizard.

## Usage

[How to Use Generator](#generator-1) and
[How to Use Reader](#reader-1)

### Generators

First, import the following frameworks:

``` swift
import RSBarcodes_Swift
import AVFoundation
```

Then, use the generator to generate a barcode. For example:

``` swift
RSUnifiedCodeGenerator.shared.generateCode("2166529V", machineReadableCodeObjectType: AVMetadataObjectTypeCode39Code)
```
It will generate a `UIImage` instance if the `2166529V` is a valid code39 string. For `AVMetadataObjectTypeCode128Code`, you can change `useBuiltInCode128Generator` to `false` to use my implementation (AutoTable for code128).

P.S. There are 4 tables for encoding a string to code128, `TableA`, `TableB`, `TableC` and `TableAuto`; the `TableAuto` is always the best choice, but if one has specific requirements, try this:

``` swift
RSCode128Generator(codeTable: .A).generateCode("123456", machineReadableCodeObjectType: AVMetadataObjectTypeCode128Code)
```
Example of these simple calls can be found in the test project.

### Reader

The following are steps to get the barcode reader working:

1. `File` -> `New` -> `File`
2. Under `iOS` click `source` and make sure `Cocoa Touch Class` is selected and hit `Next`.
3. Call the name of the class whatever you want but I will refer to it as `ScanViewController` from now on.
4. Make it a subclass of `RSCodeReaderViewController` and ensure the language is `Swift` and hit `Next` and then `Create`
5. Open your storyboard and drag a `UIViewController` onto it.
6. Show the identity inspect and under custom class select `ScanViewController`
7. The focus mark layer and corners layer are already there working for you. There are two handlers: one for the single tap on the screen along with the focus mark and one detected objects handler, which all detected will come to you. Now in the `ScanViewController.swift` file add the following code into the `viewDidLoad()` or some place more suitable for you:
  ``` swift
  override func viewDidLoad() {
      super.viewDidLoad()

      self.focusMarkLayer.strokeColor = UIColor.red.cgColor

      self.cornersLayer.strokeColor = UIColor.yellow.cgColor

      self.tapHandler = { point in
          print(point)
      }

      self.barcodesHandler = { barcodes in
          for barcode in barcodes {
              print("Barcode found: type=" + barcode.type + " value=" + barcode.stringValue)
          }
      }
  }
  ```

If you want to ignore some code types (for example, `AVMetadataObjectTypeQRCode`), add the following lines:

``` swift
let types = NSMutableArray(array: self.output.availableMetadataObjectTypes)
types.remove(AVMetadataObjectTypeQRCode)
self.output.metadataObjectTypes = NSArray(array: types)
```

### Validator

To validate codes:

``` swift
let isValid = RSUnifiedCodeValidator.shared.isValid(code, machineReadableCodeObjectType: AVMetadataObjectTypeEAN13Code)
```

### Image helpers

Use `RSAbstractCodeGenerator.resizeImage(source: UIImage, scale: CGFloat)` to scale the generated image.

Use `RSAbstractCodeGenerator.resizeImage(source: UIImage, targetSize: CGSize, contentMode: UIViewContentMode)` to fill/fit the bounds of something to the best capability and don't necessarily know what scale is too much to fill/fit, or if the `UIImageView` itself is flexible.

## Miscellaneous

[The Swift Programming Language 中文版](https://github.com/numbbbbb/the-swift-programming-language-in-chinese/)

[Online version](http://numbbbbb.github.io/the-swift-programming-language-in-chinese/) generated using [GitBook](https://www.gitbook.io/)

## License

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
