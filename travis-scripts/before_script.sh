#!/bin/sh
set -e

#workaround for TravisCI:
git --work-tree=/usr/local --git-dir=/usr/local/.git clean -fd

brew update
brew install xctool
#cd AeroDoc
#pod install
#cd ..
