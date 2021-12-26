#!/bin/sh
rm -rf ./build
xcodebuild archive -project DartNative.xcodeproj -scheme "DartNative" -sdk iphoneos15.2 OBJROOT=build/iOS
xcodebuild archive -project DartNative.xcodeproj -scheme "DartNative" -sdk iphonesimulator15.2 OBJROOT=build/simulator
xcodebuild archive -project DartNative.xcodeproj -scheme "DartNative macOS" -sdk macosx OBJROOT=build/macOS
xcodebuild -create-xcframework -framework build/macOS/UninstalledProducts/macosx/DartNative.framework -framework build/iOS/UninstalledProducts/iphoneos/DartNative.framework -framework build/simulator/UninstalledProducts/iphonesimulator/DartNative.framework -output build/DartNative.xcframework
rm -rf ./DartNative.xcframework
cp -R build/DartNative.xcframework ./DartNative.xcframework