#!/bin/sh
set -e

xctool -workspace ARIS -scheme ARIS build test
