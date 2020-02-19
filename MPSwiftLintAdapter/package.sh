#!/bin/bash
rm -rf /tmp/mpswiftlint/MPSwiftLintAdapter.app
mkdir -p /tmp/mpswiftlint
pod install
xcodebuild build -workspace MPSwiftLintAdapter.xcworkspace -scheme MPSwiftLintAdapter -configuration Release
cp -R $(./build-helper.sh) /tmp/mpswiftlint/
