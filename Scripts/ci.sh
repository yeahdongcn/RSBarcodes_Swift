set -e

xcodebuild -project RSBarcodes.xcodeproj -scheme "RSBarcodes" -destination "platform=iOS Simulator,name=iPhone 6" build

xcodebuild -project RSBarcodesSample/RSBarcodesSample.xcodeproj -scheme "RSBarcodesSample" -destination "platform=iOS Simulator,name=iPhone 6" test