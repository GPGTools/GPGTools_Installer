#!/bin/bash
##
# Click'n'go build file for the GPGTools Installer.
#
# @usage    make
# @author   Alexander Willner <alex@gpgtools.org>
# @version  2011-11-08
# @see      https://github.com/GPGTools/GPGTools_Installer
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
source "$0.config"
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
    if [ -e ".installed" ]; then rm ".installed"; fi
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
        echo "Could not get the binaries for '$5$2$3'! (1)";
        exit 1;
    fi
    exec 1>&3 2>&4
}

function subinstaller {
    cd "$1";
    echo -n "   * [`date '+%H:%M:%S'`] Getting subinstaller '$2'...";
    if [ -e '.installed' ]; then echo "skipped"; return 0; else echo ""; fi
    exec 3>&1 4>&2 >> $fileLog 2>&1
    hdiutil attach -quiet $2$3
    rm -rf "tmp";  mkdir "tmp"; cd "tmp";
    mkdir -p "$7/$6"; cd "$7/$6";
    cp "/Volumes/$4/$5" "$7/$6";
    if [ "$?" != "0" ]; then
        exec 1>&3 2>&4
        echo "Could get the subinstaller for '$1'! (2)";
        exit 1;
    fi
    touch "$1/.installed"
    hdiutil detach "/Volumes/$4";
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
        echo "Could not install the binaries for '$1'! (2)";
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
    rm -f "$7/$6/$5"
    cp -Rn "/Volumes/$4/$5" "$7/$6"
    if [ "$?" != "0" ]; then
        exec 1>&3 2>&4
        echo "Could not install the binaries for '$1'! (3)";
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
    rm -f "$5/$4/$2$3"
    cp -Rn "$1/$2$3" "$5/$4"
    if [ "$?" != "0" ]; then
        exec 1>&3 2>&4
        echo "Could not install the binaries for '$1'! (4)";
        exit 1;
    fi
    touch "$1/.installed"
    exec 1>&3 2>&4
}

################################################################################

# download files ###############################################################
echo " * Downloading the binaries in the background...";
#first one is the buffer
download "$gpgmail106_build" "$gpgmail106_version" "$gpgmail106_fileExt" "$gpgmail106_sigExt" "$gpgmail106_url"
download "$gpgmail105_build" "$gpgmail105_version" "$gpgmail105_fileExt" "$gpgmail105_sigExt" "$gpgmail105_url" &
gpgmail105_pid=${!}
download "$gpgmail107_build" "$gpgmail107_version" "$gpgmail107_fileExt" "$gpgmail107_sigExt" "$gpgmail107_url" &
gpgmail107_pid=${!}
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
download "$enigmail6_build" "$enigmail6_version" "$enigmail6_fileExt" "$enigmail6_sigExt" "$enigmail6_url" &
enigmail6_pid=${!}
download "$enigmail7_build" "$enigmail7_version" "$enigmail7_fileExt" "$enigmail7_sigExt" "$enigmail7_url" &
enigmail7_pid=${!}
download "$macgpg1_build" "$macgpg1_version" "$macgpg1_fileExt" "$macgpg1_sigExt" "$macgpg1_url" &
macgpg1_pid=${!}
download "$macgpg2_build" "$macgpg2_version" "$macgpg2_fileExt" "$macgpg2_sigExt" "$macgpg2_url" &
macgpg2_pid=${!}
################################################################################

################################################################################
echo " * Working on 'GPGMail' for 10.6...";
unpack "$gpgmail106_build"\
       "$gpgmail106_version"\
       "$gpgmail106_fileExt"\
       "$gpgmail106_volume"\
       "$gpgmail106_installer"\
       "$gpgmail106_target"\
       "$pathDist"\
       "$gpgmail106_package"
################################################################################

################################################################################
echo " * Working on 'GPGMail' for 10.7...";
waitfor "GPGMail 10.7" "$gpgmail107_pid";
subinstaller "$gpgmail107_build"\
       "$gpgmail107_version"\
       "$gpgmail107_fileExt"\
       "$gpgmail107_volume"\
       "$gpgmail107_installer"\
       "$gpgmail107_target"\
       "$pathDist"\
       "$gpgmail107_package"
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
echo " * Working on 'Enigmail' for Thunderbird 3...";
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
echo " * Working on 'Enigmail' for Thunderbird 6...";
waitfor "Enigmail for Thunderbird 6" "$enigmail6_pid";
simplecopy "$enigmail6_build"\
           "$enigmail6_version"\
           "$enigmail6_fileExt"\
           "$enigmail6_target"\
           "$pathDist"
################################################################################

################################################################################
echo " * Working on 'Enigmail' for Thunderbird 7 and 8...";
waitfor "Enigmail for Thunderbird 7 and 8" "$enigmail7_pid";
simplecopy "$enigmail7_build"\
           "$enigmail7_version"\
           "$enigmail7_fileExt"\
           "$enigmail7_target"\
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

