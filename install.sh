#!/bin/bash
sudo rm -rf /usr/local/bin/mpswiftlint /usr/local/bin/MPSwiftLintAdapter.app MPSwiftLint.pkg
./package-all.sh
sudo installer -pkg MPSwiftLint.pkg -target /