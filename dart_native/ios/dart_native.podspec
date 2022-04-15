#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint dart_native.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'dart_native'
  s.version          = '0.0.1'
  s.summary          = 'Write native code using Dart. This package liberates you from undercompetent channel.'
  s.description      = <<-DESC
Write native code using Dart. This package liberates you from undercompetent channel.
                       DESC
  s.homepage         = 'https://github.com/dart-native/dart_native'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'DartNative' => 'yulingtianxia@gmail.com' }
  s.source           = { :path => '.' }
  
  # iOS Debug
  # s.ios.source_files = 'Classes/**/*', 'common/**/*'
  # s.ios.vendored_frameworks = 'libffi.xcframework'

  # iOS Release
  s.ios.source_files = 'Classes/DartNativePlugin.*'
  s.ios.vendored_frameworks = 'DartNative.xcframework'
  
  s.public_header_files = 'Classes/DartNativePlugin.h'
  s.ios.dependency 'Flutter'

  s.ios.deployment_target = '8.0'
  s.libraries = 'c++'
  
  # Flutter.framework does not contain a i386 slice.
  s.ios.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386 arm64' }
end
