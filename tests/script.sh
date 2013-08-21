#!/bin/sh
set -e

xctool -workspace ARIS.xcworkspace -scheme 'ARIS' build test
