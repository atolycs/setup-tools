#!/usr/bin/env bash

scr_location="${HOME}/Pictures/Screenshots"

echo "Setup Screen caputure setup..."

if [ ! -d ${scr_location} ]; then
  echo "Not found"
  mkdir -p ${scr_location}
else
  echo "Exsists"
fi
