#!/bin/bash

# This script copies the bundle in the installer and 
# sets the correct value for "installKBytes" in distribution.dist

MPKG=build/GPGTools.mpkg
BUNDLE=build/payload/gpgmail107/GPGMail.mpkg/Contents/Resources/GPGMail.mailbundle
IDENTIFIER=org.gpgtools.gpgmail.pkg


# Copy $BUNDLE
cp -R "$BUNDLE" "$MPKG/Contents/Resources/"

# Calculate size of $BUNDLE
SIZE=$(du -ks "$BUNDLE" | cut -f 1) || exit 1

# Set the size in distribution.dist
sed -Ei '' 's/('"$IDENTIFIER"'.*installKBytes=")[0-9]*"/\1'"$SIZE"'"/' "$MPKG/Contents/distribution.dist" || exit 1
