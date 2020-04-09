#!/bin/zsh
MPSWIFTLINT_TEMPORARY_FOLDER=/tmp/mpswiftlint/MPSwiftLintAdapter.app
VERSION_STRING=1.0.1
OUTPUT_PACKAGE=./MPSwiftLint.pkg
DISTRIBUTION_PLIST=./mpswiftlint/Sources/Distribution.plist
cp "/tmp/mpswiftlint/mpswiftlint" "$MPSWIFTLINT_TEMPORARY_FOLDER"
pkgbuild \
        --scripts pkg-scripts \
        --identifier "com.mparticle.mpswiftlint" \
        --install-location "/tmp" \
        --root "$MPSWIFTLINT_TEMPORARY_FOLDER" \
        --version "$VERSION_STRING" \
        "$OUTPUT_PACKAGE"

sudo rm -rf /tmp/mpswiftlint