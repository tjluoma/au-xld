#!/usr/bin/env zsh -f
# install au-xld
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2013-07-02

NAME="$0:t:r"

PLIST='https://raw.github.com/tjluoma/au-xld/master/com.tjluoma.au-xld.plist'

SCRIPT='https://raw.github.com/tjluoma/au-xld/master/au-xld.sh'

INSTALL_PLIST_TO="$HOME/Library/LaunchAgents/"

INSTALL_SCRIPT_TO='/usr/local/bin'

TRASH="$HOME/.Trash"

unload () { launchctl unload "$@" }

load () {  "$@" }

die () { echo "	$NAME: $@" ; exit 1 }


####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
#		Download and install the script
#


	# now we'll run some checks to see if we'll need to use `sudo`
SUDO=''

	# if the PWD is not writable we will need to do some commands using `sudo`

[[ -d "$INSTALL_SCRIPT_TO" ]] || SUDO='sudo'
[[ -w "$INSTALL_SCRIPT_TO" ]] || SUDO='sudo'

if [[ "$SUDO" = "sudo" ]]
then
		echo "	$NAME: Before we can continue, you will need to enter your administrator password.\n\nYour password will not be stored (see 'man sudo' for more info):"

		sudo -v || die "sudo authentication failed"
fi


if [[ ! -d "$INSTALL_SCRIPT_TO" ]]
then
		echo "	$NAME: the 'INSTALL_SCRIPT_TO' folder ($INSTALL_SCRIPT_TO) does not exist. I will attempt to create it for you:"

		${SUDO} mkdir -p "$INSTALL_SCRIPT_TO" || die "failed to create $INSTALL_SCRIPT_TO (INSTALL_SCRIPT_TO) directory"

		echo "	$NAME: $INSTALL_SCRIPT_TO was successfully created. Now assigning ownership to $LOGNAME:"

		${SUDO} chown -R "${LOGNAME}" "${INSTALL_SCRIPT_TO}"  || die "failed to chown $INSTALL_SCRIPT_TO to $LOGNAME"
fi

cd "$INSTALL_SCRIPT_TO" || die "Failed to chdir to $INSTALL_SCRIPT_TO (INSTALL_SCRIPT_TO)"

	# if an old version exists, move it out of the way
[[ -e "$SCRIPT:t" ]] && ${SUDO} mv -vf "$PLIST:t" "$TRASH/"

	# Now download the new version
echo "	$NAME: [INFO] Downloading $SCRIPT to $PWD...  "

${SUDO} curl --location --remote-name "$SCRIPT" || die "curl of $SCRIPT (SCRIPT) failed."

echo "	$NAME: [INFO] making $SCRIPT:t chmod 755...  "

${SUDO} chmod 755 "$SCRIPT:t" || die "chmod 755 $SCRIPT:t failed"

echo "	$NAME: [INFO] $SCRIPT:t has successfully been installed. Next I will download and install $PLIST:t"

cd "$INSTALL_PLIST_TO" || die "Failed to chdir to $INSTALL_PLIST_TO (INSTALL_PLIST_TO)"

if [[ -e "$PLIST:t" ]]
then

		# unload com.tjluoma.au-xld if it is already loaded in `launchd`

	echo "	$NAME: [INFO] found $PLIST:t in $PWD. Trying to unload from launchd (if necessary)"

	launchctl list | fgrep -q 'com.tjluoma.au-xld' && unload com.tjluoma.au-xld

	echo "	$NAME: [INFO] found $PLIST:t in $PWD. Moving to $TRASH to make room for new version:"

	mv -vf "$PLIST:t" "$TRASH/"

fi

echo "\n	$NAME: [INFO] downloading $PLIST to $PWD..."

curl --remote-name --location "$PLIST" || die "download of PLIST failed ($PLIST)"

echo "	$NAME: $PLIST has been downloaded successfully. Now trying to load it into launchd:"

chmod 600 "$PLIST:t" || die "chmod 600 of $PLIST:t failed"

launchctl load "$PLIST:t" || die "launchctl load failed. Try rebooting"

echo "	$NAME: au-xld.sh has been successfully installed."

exit 0
#
#EOF
