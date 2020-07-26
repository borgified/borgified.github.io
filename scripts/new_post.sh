#!/usr/bin/env bash
set -e

if [ $# -lt 1 ]; then
  echo "usage: $0 [ post-title-separated-by-dashes ]"
  exit 1
fi

FRONT_MATTER_DATE=$(date +"%Y-%m-%d %k:%M:%S %z")

echo "$FRONT_MATTER"

FILENAME="$(date +"%Y-%m-%d")-$1.markdown"

echo "$FILENAME"

# https://stackoverflow.com/questions/1167746/how-to-assign-a-heredoc-value-to-a-variable-in-bash
define(){ IFS='\n' read -r -d '' ${1} || true; }

define FRONT_MATTER <<EOF
---
layout: post
title:  ""
date:   $FRONT_MATTER_DATE
categories: 
---
EOF

if [ -f "../_posts/$FILENAME" ]; then
  vi ../_posts/"$FILENAME"
else
  echo "$FRONT_MATTER" > ../_posts/"$FILENAME"
  vi ../_posts/"$FILENAME"
fi
