Pod::Spec.new do |s|
  s.name         = "RSBarcodes_Swift"
  s.version      = "4.2.1"
  s.summary      = "1D and 2D barcodes reader and generators for iOS 8 with delightful controls. Now Swift. "
  s.homepage     = "https://github.com/yeahdongcn/RSBarcodes_Swift"
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author       = { "R0CKSTAR" => "yeahdongcn@gmail.com" }
  s.platform     = :ios, '8.0'
  s.source       = { :git => 'https://github.com/yeahdongcn/RSBarcodes_Swift.git', :tag => "#{s.version}" }
  s.source_files = 'Source/*.{swift,h,m}'
  s.frameworks   = ['CoreImage', 'AVFoundation', 'QuartzCore']
  s.requires_arc = true
  s.swift_version = "4.2"
end
