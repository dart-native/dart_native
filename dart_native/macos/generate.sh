#!/bin/sh
rm -rf dart_native.podspec
rm -rf DartNative.xcframework
rm -rf Classes
rm -rf common
rm -rf libffi.xcframework
cp -R ../ios/dart_native.podspec dart_native.podspec
cp -R ../ios/DartNative.xcframework DartNative.xcframework
cp -R ../ios/Classes/ Classes/
cp -R ../ios/common/ common/
cp -R ../ios/libffi.xcframework libffi.xcframework