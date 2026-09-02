#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint amap_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_amap'
  s.version          = '2.0.0'
  s.summary          = 'AMap map, location and search plugin for Flutter'
  s.description      = <<-DESC
AMap map, location, search, weather, route query and place picker APIs for Flutter.
                       DESC
  s.homepage         = 'https://github.com/zhiye1995/flutter_amap'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'zhiye1995' => 'zhiye1995' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  if ENV['FLUTTER_AMAP_USE_NAVI_SDK'] == 'true'
    # 只在宿主同时使用导航插件时复用导航 SDK 内含的 3D 地图，避免链接两套地图实现。
    s.dependency 'AMapNavi', '= 11.2.100'
  else
    # 地图独立集成默认走此分支，不引入导航 SDK。
    s.dependency 'AMap3DMap', '= 11.2.100'
  end
  s.dependency 'AMapSearch', '= 9.8.1'
  s.dependency 'AMapLocation', '= 2.12.2'
  s.platform = :ios, '12.0'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
