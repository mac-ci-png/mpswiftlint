#!/bin/bash
xcodebuild build -workspace MPSwiftLintAdapter.xcworkspace -scheme MPSwiftLintAdapter -configuration Release | grep -o "entitlements [^ ]*" | grep MPSwiftLintAdapter.app/ | sed "s/entitlements '//" | sed "s/'//" | sed "s/MPSwiftLintAdapter.app.*/MPSwiftLintAdapter.app/"

