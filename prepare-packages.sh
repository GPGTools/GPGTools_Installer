#!/usr/bin/env bash

PWD="$(pwd)"
BUILDDIR="$PWD/build"
# The directory which contains a subdir for each package where
# the build _core.pkg is to be found.
BASEDIR=${BASEDIR:-$PWD/..}

# Include some core helper methods.
source "$(dirname "${BASH_SOURCE[0]}")/Dependencies/GPGTools_Core/newBuildSystem/core.sh"

if [ "$1" == "" ]; then
	errExit "Specify at least one package to prepare."
fi

mkdir -p "$BUILDDIR" || errExit "Failed to create $BUILDDIR. Abort!"

echoBold "Collecting core packages"
# Copy each package into the build dir.
for package in "$@"; do
	IFS=':' read -ra parts <<< "$package"
	toolName="${parts[0]}"
	packageName=${parts[1]:-${parts[0]}}
    packageCopyName="${parts[2]:-$packageName}"
	
	corePackagePath="$BASEDIR/$toolName/build/${packageName}_Core.pkg"
	corePackageDestPath="$BUILDDIR/${packageCopyName}_Core.pkg"
	
	if [ ! -f "$corePackagePath" ]; then
		echo "No such file: $corePackagePath"
		errExit "Core package of $package not available: you might have to build $package first."
	fi
	
	echo " * Copy $packageCopyName to build dir."
	cp "$corePackagePath" "$corePackageDestPath" || errExit "Failed to copy $corePackagePath to destination. Abort!"
done