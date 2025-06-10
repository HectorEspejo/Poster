#!/bin/bash

# Create a DMG installer for Poster
echo "Creating DMG installer for Poster..."

# Create a temporary directory for the DMG contents
mkdir -p dmg_temp
cp -R Poster.app dmg_temp/

# Create Applications symlink
ln -s /Applications dmg_temp/Applications

# Create the DMG
hdiutil create -volname "Poster" -srcfolder dmg_temp -ov -format UDZO Poster.dmg

# Clean up
rm -rf dmg_temp

echo "DMG created: Poster.dmg"