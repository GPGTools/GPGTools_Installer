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
export redirectCheck="REDIRECT"
source "$0.config"
################################################################################


# As default, should redirect.
if [[ ! ${!redirectCheck} && ${!redirectCheck-unset} ]]; then
	declare $redirectCheck="1"
fi

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

function shouldRedirect() {
	echo ${!redirectCheck}
}

function start_redirect_output {
	if [ "$(shouldRedirect)" == "1" ]; then
		exec 10>&1 11>&2 >> $1 2>&1
	fi
}

function end_redirect_output {
	if [ "$(shouldRedirect)" == "1" ]; then
		exec 1>&10 2>&11
	fi
}

function download {
    mkdir -p "$1"; cd "$1"
    if [ -e "$2$3" ]; then return 0; fi
    if [ -e ".installed" ]; then rm ".installed"; fi
    #echo -n "   * Downloading...";
    #if [ -e "$2$3" ]; then echo "skipped"; return 0; else echo ""; fi
    start_redirect_output "$fileLog"
    echo " ############### Download: $5$2$3"
    result=`curl --write-out %{http_code} -s -L --output /dev/null "$5$2$3"`;
    if [ "$result" != "200" ]; then
        end_redirect_output
        echo "Error $result for '$5$2$3'! (2)";
        exit 2;
    fi
    curl -s -k -L -O "$5$2$3"
    #if [ "$4" != "" ] && [ "" != "`which gpg2`" ] ; then
    #    curl -s -O "$5$2$4"
    #     gpg2 --verify "$2$4"
    #fi
    if [ "$?" != "0" ]; then
        end_redirect_output
        echo "Could not get the binaries for '$5$2$3'! (1)";
        exit 1;
    fi
    
}

function subinstaller {
    cd "$1";
    echo -n "   * [`date '+%H:%M:%S'`] Getting subinstaller '$2'...";
    if [ -e '.installed' ]; then echo "skipped"; return 0; else echo ""; fi
    start_redirect_output "$fileLog"
    hdiutil attach -quiet $2$3
    rm -rf "tmp";  mkdir "tmp"; cd "tmp";
    mkdir -p "$7/$6"; cd "$7/$6";
    cp -R "/Volumes/$4/$5" "$7/$6";
    if [ "$?" != "0" ]; then
        end_redirect_output
        echo "Could not get the subinstaller for '$1'! (2)";
        exit 1;
    fi
    touch "$1/.installed"
    hdiutil detach "/Volumes/$4";
    end_redirect_output
}


function unpack {
    cd "$1";
    echo -n "   * [`date '+%H:%M:%S'`] Unpacking '$2'...";
    if [ -e '.installed' ]; then echo "skipped"; return 0; else echo ""; fi
	start_redirect_output "$fileLog"    
	hdiutil attach -quiet $2$3
    rm -rf "tmp";  mkdir "tmp"; cd "tmp";
    xar -xf "/Volumes/$4/$5"
    mkdir -p "$7/$6"; cd "$7/$6";
    cpio -i --quiet < "$1/tmp/$8/Payload"
    if [ "$9" != "" ]; then
      cpio -i --quiet < "$1/tmp/$9/Payload"
    fi
    if [ "$?" != "0" ]; then
        end_redirect_output
        echo "Could not install the binaries for '$1'! (2)";
        exit 1;
    fi
    touch "$1/.installed"
    hdiutil detach "/Volumes/$4";
    end_redirect_output
}

function copy {
    cd "$1";
    echo -n "   * [`date '+%H:%M:%S'`] Unpacking '$2'...";
    if [ -e '.installed' ]; then echo "skipped"; return 0; else echo ""; fi
    start_redirect_output "$fileLog"
    hdiutil attach -quiet $2$3
    if [ -e "$7/$6/$5/Contents" ]; then
      rm -rf "$7/$6";
    fi
    mkdir -p "$7/$6";
    rm -f "$7/$6/$5"
    cp -Rn "/Volumes/$4/$5" "$7/$6"
    if [ "$?" != "0" ]; then
        end_redirect_output
        echo "Could not install the binaries for '$1'! (3)";
        exit 1;
    fi
    touch "$1/.installed"
    hdiutil detach "/Volumes/$4";
    end_redirect_output
}

function simplecopy {
    cd "$1";
    echo -n "   * [`date '+%H:%M:%S'`] Unpacking '$2'...";
    if [ -e '.installed' ]; then echo "skipped"; return 0; else echo ""; fi
    start_redirect_output "$fileLog"
    mkdir -p "$5/$4";
    echo "Copy: $1/$2$3 to $5/$4";
    rm -f "$5/$4/$2$3"
    cp -Rn "$1/$2$3" "$5/$4"
    if [ "$?" != "0" ]; then
        end_redirect_output
        echo "Could not install the binaries for '$1'! (4)";
        exit 1;
    fi
    touch "$1/.installed"
    end_redirect_output
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
download "$gka105_build" "$gka105_version" "$gka105_fileExt" "$gka105_sigExt" "$gka105_url" &
gka105_pid=${!}
download "$gpgservices_build" "$gpgservices_version" "$gpgservices_fileExt" "$gpgservices_sigExt" "$gpgservices_url" &
gpgservices_pid=${!}
download "$gpgpreferences_build" "$gpgpreferences_version" "$gpgpreferences_fileExt" "$gpgpreferences_sigExt" "$gpgpreferences_url" &
gpgpreferences_pid=${!}
#download "$enigmail_build" "$enigmail_version" "$enigmail_fileExt" "$enigmail_sigExt" "$enigmail_url" &
#enigmail_pid=${!}
#download "$enigmail5_build" "$enigmail5_version" "$enigmail5_fileExt" "$enigmail5_sigExt" "$enigmail5_url" &
#enigmail5_pid=${!}
#download "$enigmail6_build" "$enigmail6_version" "$enigmail6_fileExt" "$enigmail6_sigExt" "$enigmail6_url" &
#enigmail6_pid=${!}
#download "$enigmail7_build" "$enigmail7_version" "$enigmail7_fileExt" "$enigmail7_sigExt" "$enigmail7_url" &
#enigmail7_pid=${!}
#download "$enigmail8_build" "$enigmail8_version" "$enigmail8_fileExt" "$enigmail8_sigExt" "$enigmail8_url" &
#enigmail8_pid=${!}
#download "$enigmail9_build" "$enigmail9_version" "$enigmail9_fileExt" "$enigmail9_sigExt" "$enigmail9_url" &
#enigmail9_pid=${!}
download "$enigmail_latest_build" "$enigmail_latest_version" "$enigmail_latest_fileExt" "$enigmail_latest_sigExt" "$enigmail_latest_url" &
enigmail_latest_pid=${!}

#download "$macgpg1_build" "$macgpg1_version" "$macgpg1_fileExt" "$macgpg1_sigExt" "$macgpg1_url" &
#macgpg1_pid=${!}
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
echo " * Working on 'GPG Keychain Access' for 10.5...";
waitfor "GPG Keychain Access for 10.5" "$gka105_pid";
copy "$gka105_build"\
      "$gka105_version"\
      "$gka105_fileExt"\
      "$gka105_volume"\
      "$gka105_installer"\
      "$gka105_target"\
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
subinstaller "$gpgservices_build"\
       "$gpgservices_version"\
       "$gpgservices_fileExt"\
       "$gpgservices_volume"\
       "$gpgservices_installer"\
       "$gpgservices_target"\
       "$pathDist"\
       "$gpgservices_package"
################################################################################

################################################################################
#echo " * Working on 'Enigmail' for Thunderbird 3...";
#waitfor "Enigmail" "$enigmail_pid";
#simplecopy "$enigmail_build"\
#           "$enigmail_version"\
#           "$enigmail_fileExt"\
#           "$enigmail_target"\
#           "$pathDist"
################################################################################

################################################################################
#echo " * Working on 'Enigmail' for Thunderbird 5...";
#waitfor "Enigmail for Thunderbird 5" "$enigmail5_pid";
#simplecopy "$enigmail5_build"\
#           "$enigmail5_version"\
#           "$enigmail5_fileExt"\
#           "$enigmail5_target"\
#           "$pathDist"
################################################################################

################################################################################
#echo " * Working on 'Enigmail' for Thunderbird 6...";
#waitfor "Enigmail for Thunderbird 6" "$enigmail6_pid";
#simplecopy "$enigmail6_build"\
#           "$enigmail6_version"\
#           "$enigmail6_fileExt"\
#           "$enigmail6_target"\
#           "$pathDist"
################################################################################

################################################################################
#echo " * Working on 'Enigmail' for Thunderbird 7...";
#waitfor "Enigmail for Thunderbird 7" "$enigmail7_pid";
#simplecopy "$enigmail7_build"\
#           "$enigmail7_version"\
#           "$enigmail7_fileExt"\
#           "$enigmail7_target"\
#           "$pathDist"
################################################################################

################################################################################
#echo " * Working on 'Enigmail' for Thunderbird 8...";
#waitfor "Enigmail for Thunderbird 8" "$enigmail8_pid";
#simplecopy "$enigmail8_build"\
#           "$enigmail8_version"\
#           "$enigmail8_fileExt"\
#           "$enigmail8_target"\
#           "$pathDist"
################################################################################

################################################################################
#echo " * Working on 'Enigmail' for Thunderbird 9...";
#waitfor "Enigmail for Thunderbird 9" "$enigmail9_pid";
#simplecopy "$enigmail9_build"\
#           "$enigmail9_version"\
#           "$enigmail9_fileExt"\
#           "$enigmail9_target"\
#           "$pathDist"
################################################################################

################################################################################
echo " * Working on 'Enigmail' for latest Thunderbird...";
waitfor "Enigmail for latest Thunderbird" "$enigmail_latest_pid";
simplecopy "$enigmail_latest_build"\
           "$enigmail_latest_version"\
           "$enigmail_latest_fileExt"\
           "$enigmail_latest_target"\
           "$pathDist"
################################################################################

################################################################################
#echo " * Working on 'MacGPG1'...";
#waitfor "$macgpg1_target" "$macgpg1_pid";
#unpack "$macgpg1_build"\
#       "$macgpg1_version"\
#       "$macgpg1_fileExt"\
#       "$macgpg1_volume"\
#       "$macgpg1_installer"\
#       "$macgpg1_target"\
#       "$pathDist"\
#       "$macgpg1_package"
################################################################################

################################################################################
#echo " * Working on 'MacGPG2'...";
#waitfor "MacGPG2" "$macgpg2_pid";
#unpack "$macgpg2_build"\
#       "$macgpg2_version"\
#       "$macgpg2_fileExt"\
#       "$macgpg2_volume"\
#       "$macgpg2_installer"\
#       "$macgpg2_target"\
#       "$pathDist"\
#       "$macgpg2_package"\
#       "$macgpg2_package2"
################################################################################

################################################################################
echo " * Working on 'MacGPG2 (Core)'...";
waitfor "MacGPG2" "$macgpg2_pid";
subinstaller "$macgpg2_build"\
       "$macgpg2_version"\
       "$macgpg2_fileExt"\
       "$macgpg2_volume"\
       "$macgpg2_installer"\
       "$macgpg2_target"\
       "$pathDist"\
       "$macgpg2_package"
#echo " * Working on 'MacGPG2 (Pinentry)'...";
#rm "$macgpg2_build/.installed"
#subinstaller "$macgpg2_build"\
#       "$macgpg2_version"\
#       "$macgpg2_fileExt"\
#       "$macgpg2_volume"\
#       "$macgpg2_installer2"\
#       "$macgpg2_target"\
#       "$pathDist"\
#       "$macgpg2_package"
################################################################################


exit

#-------------------------------------------------------------------------
read -p "Compile sources [y/n]? " input

if [ "x$input" == "xy" -o "x$input" == "xY" ] ;then
    back="`pwd`";
    echo "Compiling GPGPreferences...";
    mkdir -p payload/gpgtoolspreferences
    (cd ../GPGPreferences && git pull && git submodule foreach git pull origin master && make && cd "$back" && rm -rf payload/gpgtoolspreferences/GPGTools.prefPane && cp -R ../GPGPreferences/build/Release/GPGTools.prefPane payload/gpgtoolspreferences/) > build.log 2>&1
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

