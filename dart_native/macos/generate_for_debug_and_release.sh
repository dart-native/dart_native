#!/bin/sh
rm -rf Classes
rm -rf common
rm -rf libffi.xcframework
cp -R ../ios/Classes/ Classes/
cp -R ../ios/common/ common/
cp -R ../ios/libffi.xcframework libffi.xcframework