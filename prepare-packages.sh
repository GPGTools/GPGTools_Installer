#!/usr/bin/env bash

PWD="$(pwd)"
BUILDDIR="$PWD/build"
PKGPROJ="GPGTools_Installer.pkgproj"
PKGPROJ_PATH="$PWD/Installer/$PKGPROJ"

# Include some core helper methods.
source "$(dirname "${BASH_SOURCE[0]}")/Dependencies/GPGTools_Core/newBuildSystem/core.sh"

# The directory which contains a subdir for each package where
# the build _core.pkg is to be found.
BASEDIR="$1"
if [ "$BASEDIR" == "" ]; then
	errExit "You have to specify the location of the core packages."
fi

echo "Looking for core packages in $BASEDIR"

mkdir -p "$BUILDDIR" || errExit "Failed to create $BUILDDIR. Abort!"

if [ ! -d "$1" ]; then
	errExit "Location of core packages doesn't exist: $1"
fi

ANY_CORE_PACKAGES=$(ls -l "$BASEDIR"/*_Core.pkg &>/dev/null; test "$?" -eq "1" && echo "0" || echo "1")

if [ "$ANY_CORE_PACKAGES" != "1" ]; then
	errExit "No core packages found."
fi

REQUIRED_PACKAGES=$(grep '>\.\./build/' "$PKGPROJ_PATH" | sed "s/<string>//" | sed "s/<\/string>//" | sed 's/..\/build\///' | sed 's/\n//')
CLEAN_REQUIRED_PACKAGES=""

echo "Found core pacakges: ${FOUND_CORE_PACKAGES}"

# I hate those whitespaces.
echoBold "Required core packages:"
for package in $REQUIRED_PACKAGES; do
	CLEAN_REQUIRED_PACKAGES="$CLEAN_REQUIRED_PACKAGES $package"
	echo " * $package"
done

echoBold "Copying core packages to build folder."

# Copy each package into the build dir.
for package in $CLEAN_REQUIRED_PACKAGES; do
	corePackagePath="$BASEDIR/$package"
	corePackageDestPath="$BUILDDIR/$package"
	
	if [ ! -f "$corePackagePath" ]; then
		echo "No such file: $corePackagePath"
		errExit "Core package $package not available: you might have to build it first."
	fi
	
	echo " * Copy $package to build dir."
	cp "$corePackagePath" "$corePackageDestPath" || errExit "Failed to copy $corePackagePath to destination. Abort!"
done
echoBold "Done!"