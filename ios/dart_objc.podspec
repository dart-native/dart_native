#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint dart_objc.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'dart_objc'
  s.version          = '0.0.1'
  s.summary          = 'Write Objective-C Code using Dart'
  s.description      = <<-DESC
Write Objective-C Code using Dart. This package liberates you from native code and low performance channel.
                       DESC
  s.homepage         = 'http://yulingtianxia.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'yulingtianxia' => 'yulingtianxia@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*', 'libffi/*.h'
  mrc_files = 'Classes/native_runtime.*'
  s.exclude_files = mrc_files
  s.public_header_files = 'Classes/DartObjcPlugin.h'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'
  s.requires_arc = true
  s.vendored_libraries = "libffi/libffi.a"
  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  
  s.subspec 'Runtime' do |ss|
    ss.requires_arc = false
    ss.source_files = mrc_files
  end
end
