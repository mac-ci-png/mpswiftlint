#!/bin/bash
rm -rf /tmp/mpswiftlint/mpswiftlint;
mkdir -p /tmp/mpswiftlint
swift build --configuration release
cp .build/release/mpswiftlint /tmp/mpswiftlint/mpswiftlint
