#!/bin/bash

SIZES="29 40 50 57 58 72 76 80 87 100 114 120 144 152 167 180"

for s in $SIZES; do
  convert root.png -resize ${s}x${s} ${s}x${s}.png
done

