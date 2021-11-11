#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint dart_native.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'dart_native'
  s.version          = '0.0.1'
  s.summary          = 'Write native code using Dart. This package liberates you from native code and low performance channel.'
  s.description      = <<-DESC
Write native code using Dart. This package liberates you from native code and low performance channel.
                       DESC
  s.homepage         = 'https://github.com/dart-native/dart_native'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'DartNative' => 'email@example.com' }
  s.source           = { :path => '.' }
  
  # Debug
  # s.source_files = 'Classes/**/*', 'libffi/*.h', 'common/**/*'
  # s.vendored_libraries = 'libffi/libffi.a'

  # Release
  s.source_files = 'Classes/DartNativePlugin.*'
  s.vendored_frameworks = 'DartNative.xcframework'
  
  s.public_header_files = 'Classes/DartNativePlugin.h', 'Classes/native_runtime.h', 'Classes/DNMacro.h', 'common/include/dart_api_dl.h', 'common/include/dart_api.h', 'common/include/dart_native_api.h'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'
  s.libraries = 'c++'
  
  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end
