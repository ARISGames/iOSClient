#!/bin/sh
set -e

xctool -workspace ARIS.xcworkspace -sdk 'iphonesimulator' -scheme 'ARIS' -configuration 'Debug' build test
