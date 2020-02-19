#!/bin/bash

cd ./MPSwiftLintAdapter
./package.sh
cd ..

cd ./MPSwiftLint
./package.sh
cd ..

./package.sh
