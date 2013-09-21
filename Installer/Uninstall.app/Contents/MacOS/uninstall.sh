#!/bin/bash

if [[ $UID -ne 0 ]] ;then
	bundle="${0%/*}/../.."
	
	# Hell this is ugly, but unfortunately spaces have to be escaped
	# for Apple Script as they are in a shell with \, but \ is special
	# in Apple Script so we have to escape \ as well, which means
	# "test folder" is escaped to "test\\ folder"
	escape_filed_path=$(echo $0 | sed "s/ /\\\\\\\\ /g")
	
	osascript -e '
	set bndl to POSIX file "'"$bundle"'"
	set question to localized string "question" in bundle bndl
	set cancel to localized string "Cancel" in bundle bndl
	set uninstall to localized string "Uninstall" in bundle bndl
	activate
	display dialog question buttons {cancel, uninstall} default button uninstall
	try
		quit application id "com.apple.mail"
	end try
	try
		quit application id "org.gpgtools.gpgkeychainaccess"
	end try
	try
		quit application id "org.gpgtools.gpgservices"
	end try
	do shell script "'"$escape_filed_path"'" with administrator privileges
	set succeeded to localized string "succeeded" in bundle bndl
	set ok to localized string "OK" in bundle bndl
	activate
	display dialog succeeded buttons {ok} default button ok
	'
	exit
fi

function rmv () {
	rm -f "$@"
}

# Kill the gpg-agent
killall -9 gpg-agent
# Kill the XPC service.
launchctl unload /Library/LaunchAgents/org.gpgtools.Libmacgpg.xpc.plist

rmv -r /Library/Services/GPGServices.service "$HOME"/Library/Services/GPGServices.service
rmv -r /Library/Mail/Bundles/GPGMail.mailbundle "$HOME"/Library/Mail/Bundles/GPGMail.mailbundle /Network/Library/Mail/Bundles/GPGMail.mailbundle
rmv -r /usr/local/MacGPG2
rmv -r /private/etc/paths.d/MacGPG2
rmv -r /private/etc/manpaths.d/MacGPG2

[[ "$(readlink /usr/local/bin/gpg2)" =~ MacGPG2 ]] && rmv /usr/local/bin/gpg2
[[ "$(readlink /usr/local/bin/gpg)" =~ MacGPG2 ]] && rmv /usr/local/bin/gpg
[[ "$(readlink /usr/local/bin/gpg-agent)" =~ MacGPG2 ]] && rmv /usr/local/bin/gpg-agent
rmv -r /Library/PreferencePanes/GPGPreferences.prefPane "$HOME"/Library/PreferencePanes/GPGPreferences.prefPane

gkaLocation=$(mdfind -onlyin /Applications "kMDItemCFBundleIdentifier = org.gpgtools.gpgkeychainaccess" | head -1)
gkaLocation=${gkaLocation:-/Applications/GPG Keychain Access.app}
rmv -r "$gkaLocation"

if pushd /Library/LaunchAgents &>/dev/null ;then
	rmv org.gpgtools.Libmacgpg.xpc.plist org.gpgtools.gpgmail.patch-uuid-user.plist org.gpgtools.macgpg2.fix.plist org.gpgtools.macgpg2.shutdown-gpg-agent.plist org.gpgtools.macgpg2.updater.plist org.gpgtools.macgpg2.gpg-agent.plist
	popd &>/dev/null
fi

rmv /Library/LaunchDaemons/org.gpgtools.gpgmail.patch-uuid.plist

rmv "$HOME/Library/Preferences/org.gpgtools."*
rmv "$HOME/Library/Containers/com.apple.mail/Data/Library/Preferences/org.gpgtools."*
rmv -r "/Library/Application Support/GPGTools" "$HOME/Library/Application Support/GPGTools"
rmv -r "/Library/Frameworks/Libmacgpg.framework" "$HOME/Library/Frameworks/Libmacgpg.framework" "$HOME/Containers/com.apple.mail/Data/Library/Frameworks/Libmacgpg.framework"

pkgutil --regexp --forget 'org\.gpgtools\..*'

exit 0
