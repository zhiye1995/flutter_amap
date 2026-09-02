#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint amap_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_amap_navi'
  s.version          = '1.0.0'
  s.summary          = 'AMap navigation plugin for Flutter'
  s.description      = <<-DESC
AMap drive, walk, ride navigation and cruise events for Flutter.
                       DESC
  s.homepage         = 'https://github.com/zhiye1995/flutter_amap'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'zhiye1995' => 'zhiye1995' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'AMapNavi', '= 11.2.100'
  s.platform = :ios, '12.0'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
