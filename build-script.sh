#!/bin/bash
##
# Click'n'go build file for the GPGTools Installer.
#
# @usage    make
# @author   Alexander Willner <alex@gpgtools.org>
# @version  2011-06-20
# @see      https://github.com/GPGTools/GPGTools_Installer
#
# @todo     tbd
##

# configuration ################################################################
## where to start from
export pathRoot="`pwd`";
## where to download the files to
export pathDownload="$pathRoot/build";
## where to copy the binaries to
export pathDist="$pathDownload/payload/";
## logging
export fileLog="$pathDownload/build.log";
################################################################################

# the releases #################################################################
gka_url="https://github.com/downloads/GPGTools/GPGKeychainAccess/";
gka_version="GPG%20Keychain%20Access-0.8.10";
gka_fileExt=".dmg";
gka_sigExt=".dmg.sig"
gka_build="$pathDownload/gka";
gka_volume="GPG Keychain Access.localized";
gka_installer="GPG Keychain Access.app";
gka_target="keychain_access";

gpgmail_url="https://github.com/downloads/GPGTools/GPGMail/";
gpgmail_version="GPGMail-1.3.3";
gpgmail_fileExt=".dmg";
gpgmail_sigExt=".dmg.sig"
gpgmail_build="$pathDownload/gpgmail";
gpgmail_volume="GPGMail";
gpgmail_installer="GPGMail.pkg";
gpgmail_package="GPGMail.pkg"
gpgmail_target="gpgmail";

gpgmail105_url="https://github.com/downloads/GPGTools/GPGMail/";
gpgmail105_version="GPGMail-1.2.0-10.5";
gpgmail105_fileExt=".dmg";
gpgmail105_sigExt=".dmg.sig"
gpgmail105_build="$pathDownload/gpgmail105";
gpgmail105_volume="GPGMail 1.2.0";
gpgmail105_installer="GPGMail.mailbundle";
gpgmail105_target="gpgmail105";

#gpgmail104_url="https://github.com/downloads/GPGTools/GPGMail/";
#gpgmail104_version="GPGMail-1.1.2-10.4";
#gpgmail104_fileExt=".dmg";
#gpgmail104_sigExt=".dmg.sig"
#gpgmail104_build="$pathDownload/gpgmail104";
#gpgmail104_volume="GPGMail-1.1.2-10.4";
#gpgmail104_installer="GPGMail.mailbundle";
#gpgmail104_target="gpgmail104";

macgpg2_url="https://github.com/downloads/GPGTools/MacGPG2/";
macgpg2_version="MacGPG2-2.0.17-9";
macgpg2_fileExt=".dmg";
macgpg2_sigExt=".dmg.sig"
macgpg2_build="$pathDownload/macgpg2";
macgpg2_volume="MacGPG2";
macgpg2_installer="$macgpg2_version.pkg";
macgpg2_package="macgpg2.pkg";
macgpg2_package2="gnupg2.pkg";
macgpg2_target="MacGPG2";

macgpg1_url="https://github.com/downloads/GPGTools/MacGPG1/";
macgpg1_version="MacGPG1-1.4.11-6";
macgpg1_fileExt=".dmg";
macgpg1_sigExt=".dmg.sig"
macgpg1_build="$pathDownload/macgpg1";
macgpg1_volume="MacGPG1";
macgpg1_installer="MacGPG1.pkg";
macgpg1_package="MacGPG1.pkg";
macgpg1_target="MacGPG1";

enigmail_url="http://addons.mozilla.org/en-US/thunderbird/downloads/file/92939/";
enigmail_version="enigmail-1.1.2-tb-macosx";
enigmail_fileExt=".xpi";
enigmail_sigExt=".xpi.sig"
enigmail_build="$pathDownload/enigmail";
enigmail_target="enigmail";

enigmail5_url="http://addons.mozilla.org/thunderbird/downloads/file/124320/";
enigmail5_version="enigmail-1.2-sm-mac";
enigmail5_fileExt=".xpi";
enigmail5_sigExt=".xpi.sig"
enigmail5_build="$pathDownload/enigmail5";
enigmail5_target="enigmail5";

gpgservices_url="https://github.com/downloads/GPGTools/GPGServices/";
gpgservices_version="GPGServices-1.6";
gpgservices_fileExt=".dmg";
gpgservices_sigExt=".dmg.sig"
gpgservices_build="$pathDownload/gpgservices";
gpgservices_volume="GPGServices";
gpgservices_installer="GPGServices.mpkg/Contents/Packages/GPGServices.pkg";
gpgservices_package="."
gpgservices_target="gpgservices";


gpgpreferences_url="https://github.com/downloads/GPGTools/GPGTools_Preferences/";
gpgpreferences_version="GPGPreferences-0.6";
gpgpreferences_fileExt=".dmg";
gpgpreferences_sigExt=".dmg.sig"
gpgpreferences_build="$pathDownload/gpgpreferences";
gpgpreferences_volume="gpgpreferences";
gpgpreferences_installer="GPGTools.prefPane";
gpgpreferences_target="gpgtoolspreferences";
################################################################################

# init #########################################################################
if [ "`which curl`" == "" ]; then
    echo " * ERROR: Please install 'curl' first :/";
    exit 1
fi

echo "Configuration:";
echo " * Target: $pathDist"; mkdir -p "$pathDist";
echo " * Log: $fileLog"; :> "$fileLog";
echo "Downloading releases:";
################################################################################

################################################################################
if [ "$1" == "clean" ]; then
    rm "$fileLog"
    rm -rf "$pathDownload"
    rm -rf "$pathDist"
fi
################################################################################


# functions ####################################################################
function waitfor {
    echo "   * [`date '+%H:%M:%S'`] Waiting for download of '$1'...";
    wait "$2";
}

function download {
    mkdir -p "$1"; cd "$1"
    if [ -e "$2$3" ]; then return 0; fi
    #echo -n "   * Downloading...";
    #if [ -e "$2$3" ]; then echo "skipped"; return 0; else echo ""; fi
    exec 3>&1 4>&2 >> $fileLog 2>&1
    echo " ############### Download: $5$2$3"
    curl -s -C - -L -O "$5$2$3"
    #if [ "$4" != "" ] && [ "" != "`which gpg2`" ] ; then
    #    curl -s -O "$5$2$4"
    #     gpg2 --verify "$2$4"
    #fi
    if [ "$?" != "0" ]; then
        exec 1>&3 2>&4
        echo "Could not get the binaries for '$5$2$3'!";
        exit 1;
    fi
    exec 1>&3 2>&4
}

function unpack {
    cd "$1";
    echo -n "   * [`date '+%H:%M:%S'`] Unpacking '$2'...";
    if [ -e '.installed' ]; then echo "skipped"; return 0; else echo ""; fi
    exec 3>&1 4>&2 >> $fileLog 2>&1
    hdiutil attach -quiet $2$3
    rm -rf "tmp";  mkdir "tmp"; cd "tmp";
    xar -xf "/Volumes/$4/$5"
    mkdir -p "$7/$6"; cd "$7/$6";
    cpio -i --quiet < "$1/tmp/$8/Payload"
    if [ "$9" != "" ]; then
      cpio -i --quiet < "$1/tmp/$9/Payload"
    fi
    if [ "$?" != "0" ]; then
        exec 1>&3 2>&4
        echo "Could not install the binaries for '$1'!";
        exit 1;
    fi
    touch "$1/.installed"
    hdiutil detach "/Volumes/$4";
    exec 1>&3 2>&4
}

function copy {
    cd "$1";
    echo -n "   * [`date '+%H:%M:%S'`] Unpacking '$2'...";
    if [ -e '.installed' ]; then echo "skipped"; return 0; else echo ""; fi
    exec 3>&1 4>&2 >> $fileLog 2>&1
    hdiutil attach -quiet $2$3
    if [ -e "$7/$6/$5/Contents" ]; then
      rm -rf "$7/$6";
    fi
    mkdir -p "$7/$6";
    cp -Rn "/Volumes/$4/$5" "$7/$6"
    if [ "$?" != "0" ]; then
        exec 1>&3 2>&4
        echo "Could not install the binaries for '$1'!";
        exit 1;
    fi
    touch "$1/.installed"
    hdiutil detach "/Volumes/$4";
    exec 1>&3 2>&4
}

function simplecopy {
    cd "$1";
    echo -n "   * [`date '+%H:%M:%S'`] Unpacking '$2'...";
    if [ -e '.installed' ]; then echo "skipped"; return 0; else echo ""; fi
    exec 3>&1 4>&2 >> $fileLog 2>&1
    mkdir -p "$5/$4";
    echo "Copy: $1/$2$3 to $5/$4";
    cp -Rn "$1/$2$3" "$5/$4"
    if [ "$?" != "0" ]; then
        exec 1>&3 2>&4
        echo "Could not install the binaries for '$1'!";
        exit 1;
    fi
    touch "$1/.installed"
    exec 1>&3 2>&4
}

################################################################################

# download files ###############################################################
echo " * Downloading the binaries in the background...";
#first one is the buffer
download "$gpgmail_build" "$gpgmail_version" "$gpgmail_fileExt" "$gpgmail_sigExt" "$gpgmail_url"
download "$gpgmail105_build" "$gpgmail105_version" "$gpgmail105_fileExt" "$gpgmail105_sigExt" "$gpgmail105_url" &
gpgmail105_pid=${!}
#download "$gpgmail104_build" "$gpgmail104_version" "$gpgmail104_fileExt" "$gpgmail104_sigExt" "$gpgmail104_url" &
#gpgmail104_pid=${!}
download "$gka_build" "$gka_version" "$gka_fileExt" "$gka_sigExt" "$gka_url" &
gka_pid=${!}
download "$gpgservices_build" "$gpgservices_version" "$gpgservices_fileExt" "$gpgservices_sigExt" "$gpgservices_url" &
gpgservices_pid=${!}
download "$gpgpreferences_build" "$gpgpreferences_version" "$gpgpreferences_fileExt" "$gpgpreferences_sigExt" "$gpgpreferences_url" &
gpgpreferences_pid=${!}
download "$enigmail_build" "$enigmail_version" "$enigmail_fileExt" "$enigmail_sigExt" "$enigmail_url" &
enigmail_pid=${!}
download "$enigmail5_build" "$enigmail5_version" "$enigmail5_fileExt" "$enigmail5_sigExt" "$enigmail5_url" &
enigmail5_pid=${!}
download "$macgpg1_build" "$macgpg1_version" "$macgpg1_fileExt" "$macgpg1_sigExt" "$macgpg1_url" &
macgpg1_pid=${!}
download "$macgpg2_build" "$macgpg2_version" "$macgpg2_fileExt" "$macgpg2_sigExt" "$macgpg2_url" &
macgpg2_pid=${!}
################################################################################

################################################################################
echo " * Working on 'GPGMail'...";
unpack "$gpgmail_build"\
       "$gpgmail_version"\
       "$gpgmail_fileExt"\
       "$gpgmail_volume"\
       "$gpgmail_installer"\
       "$gpgmail_target"\
       "$pathDist"\
       "$gpgmail_package"
################################################################################

################################################################################
echo " * Working on 'GPGMail for 10.5'...";
waitfor "GPGMail 10.5" "$gpgmail105_pid";
copy "$gpgmail105_build"\
      "$gpgmail105_version"\
      "$gpgmail105_fileExt"\
      "$gpgmail105_volume"\
      "$gpgmail105_installer"\
      "$gpgmail105_target"\
      "$pathDist"
################################################################################

################################################################################
#echo " * Working on 'GPGMail for 10.4'...";
#waitfor "GPGMail 10.4" "$gpgmail104_pid";
#copy "$gpgmail104_build"\
#      "$gpgmail104_version"\
#      "$gpgmail104_fileExt"\
#      "$gpgmail104_volume"\
#      "$gpgmail104_installer"\
#      "$gpgmail104_target"\
#      "$pathDist"
################################################################################

################################################################################
echo " * Working on 'GPG Keychain Access'...";
waitfor "GPG Keychain Access" "$gka_pid";
copy "$gka_build"\
      "$gka_version"\
      "$gka_fileExt"\
      "$gka_volume"\
      "$gka_installer"\
      "$gka_target"\
      "$pathDist"
################################################################################

################################################################################
echo " * Working on 'GPG Preferences'...";
waitfor "GPG Preferences" "$gpgpreferences_pid";
copy "$gpgpreferences_build"\
     "$gpgpreferences_version"\
     "$gpgpreferences_fileExt"\
     "$gpgpreferences_volume"\
     "$gpgpreferences_installer"\
     "$gpgpreferences_target"\
     "$pathDist"
################################################################################

################################################################################
echo " * Working on 'GPGServices'...";
waitfor "GPGServices" "$gpgservices_pid";
unpack "$gpgservices_build"\
       "$gpgservices_version"\
       "$gpgservices_fileExt"\
       "$gpgservices_volume"\
       "$gpgservices_installer"\
       "$gpgservices_target"\
       "$pathDist"\
       "$gpgservices_package"
################################################################################

################################################################################
echo " * Working on 'Enigmail'...";
waitfor "Enigmail" "$enigmail_pid";
simplecopy "$enigmail_build"\
           "$enigmail_version"\
           "$enigmail_fileExt"\
           "$enigmail_target"\
           "$pathDist"
################################################################################

################################################################################
echo " * Working on 'Enigmail' for Thunderbird 5...";
waitfor "Enigmail for Thunderbird 5" "$enigmail5_pid";
simplecopy "$enigmail5_build"\
           "$enigmail5_version"\
           "$enigmail5_fileExt"\
           "$enigmail5_target"\
           "$pathDist"
################################################################################

################################################################################
echo " * Working on 'MacGPG1'...";
waitfor "$macgpg1_target" "$macgpg1_pid";
unpack "$macgpg1_build"\
       "$macgpg1_version"\
       "$macgpg1_fileExt"\
       "$macgpg1_volume"\
       "$macgpg1_installer"\
       "$macgpg1_target"\
       "$pathDist"\
       "$macgpg1_package"
################################################################################

################################################################################
echo " * Working on 'MacGPG2'...";
waitfor "MacGPG2" "$macgpg2_pid";
unpack "$macgpg2_build"\
       "$macgpg2_version"\
       "$macgpg2_fileExt"\
       "$macgpg2_volume"\
       "$macgpg2_installer"\
       "$macgpg2_target"\
       "$pathDist"\
       "$macgpg2_package"\
       "$macgpg2_package2"
################################################################################

exit

#-------------------------------------------------------------------------
read -p "Compile sources [y/n]? " input

if [ "x$input" == "xy" -o "x$input" == "xY" ] ;then
    back="`pwd`";
    echo "Compiling GPGTools_Preferences...";
    mkdir -p payload/gpgtoolspreferences
    (cd ../GPGTools_Preferences && git pull && git submodule foreach git pull origin master && make && cd "$back" && rm -rf payload/gpgtoolspreferences/GPGTools.prefPane && cp -R ../GPGTools_Preferences/build/Release/GPGTools.prefPane payload/gpgtoolspreferences/) > build.log 2>&1
    if [ ! "$?" == "0" ]; then echo "ERROR. Look at build.log"; exit 1; fi
    echo "Compiling GPGServices...";
    mkdir -p payload/gpgservices
    (cd ../GPGServices && git pull && git submodule foreach git pull origin master && make && cd "$back" && rm -rf payload/gpgservices/GPGServices.service && cp -R ../GPGServices/build/Release/GPGServices.service payload/gpgservices/) > build.log 2>&1
    if [ ! "$?" == "0" ]; then echo "ERROR. Look at build.log"; exit 1; fi
    echo "Compiling GPGKeychainAccess..."
    mkdir -p payload/keychain_access
    (cd ../GPGKeychainAccess && git pull && git submodule foreach git pull origin master && make && cd "$back" && rm -rf payload/keychain_access/Applications/GPG\ Keychain\ Access.app && cp -R ../GPGKeychainAccess/build/Release/GPG\ Keychain\ Access.app payload/keychain_access/Applications/)  > build.log 2>&1
    if [ ! "$?" == "0" ]; then echo "ERROR. Look at build.log"; exit 1; fi
    echo "Compiling GPGMail...";
    mkdir -p payload/gpgmail
    (cd ../GPGMail && git pull && git submodule foreach git pull origin master && make && cd "$back" && rm -rf payload/gpgmail/GPGMail.mailbundle && cp -R ../GPGMail/build/Release/GPGMail.mailbundle payload/gpgmail/)  > build.log 2>&1
    if [ ! "$?" == "0" ]; then echo "ERROR. Look at build.log"; exit 1; fi
    echo "Compiling MacGPG2...";
    mkdir -p payload/gpg2
    (cd ../MacGPG2 && git pull && git submodule foreach git pull origin master && make && cd "$back" && rm -rf payload/gpg2/* && cp -R ../MacGPG2/build/* payload/gpg2/) > build.log 2>&1
    if [ ! "$?" == "0" ]; then echo "ERROR. Look at build.log"; exit 1; fi
fi
#-------------------------------------------------------------------------

