#!/bin/sh
rm -rf ./build
xcodebuild archive -project DartNative.xcodeproj -scheme "DartNative" -sdk iphoneos14.5 OBJROOT=build/iOS
xcodebuild archive -project DartNative.xcodeproj -scheme "DartNative" -sdk iphonesimulator14.5 OBJROOT=build/simulator
xcodebuild -create-xcframework -framework build/iOS/UninstalledProducts/iphoneos/DartNative.framework -framework build/simulator/UninstalledProducts/iphonesimulator/DartNative.framework -output build/DartNative.xcframework
rm -rf ./DartNative.xcframework
cp -R build/DartNative.xcframework ./DartNative.xcframework