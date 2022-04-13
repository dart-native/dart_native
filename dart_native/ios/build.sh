#!/bin/sh
rm -rf ./build
xcodebuild archive -project DartNative.xcodeproj -scheme "DartNative" -sdk iphoneos OBJROOT=build/iOS
xcodebuild archive -project DartNative.xcodeproj -scheme "DartNative" -sdk iphonesimulator OBJROOT=build/simulator
xcodebuild -create-xcframework -framework build/iOS/UninstalledProducts/iphoneos/DartNative.framework -framework build/simulator/UninstalledProducts/iphonesimulator/DartNative.framework -output build/DartNative.xcframework
rm -rf ./DartNative.xcframework
cp -R build/DartNative.xcframework ./DartNative.xcframework
# copy for macOS
cd ../macos
sh generate_for_debug_and_release.sh