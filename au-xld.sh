#!/usr/bin/env zsh -f
# download and install XLD, but only if there is a newer version available
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2013-07-02


	# Change this if you want XLD.app installed somewhere else. Default:
	# APPDIR="/Applications"
APPDIR="/Applications"

	# Change this if you want downloads stored somewhere else.  Default:
	# DL_DIR="$HOME/Downloads"
DL_DIR="$HOME/Downloads"

	# Old versions of the app will be moved here. Default:
	# TRASH="$HOME/.Trash/"
TRASH="$HOME/.Trash/"

	# set to 'no' to not have a notification of new version installation
	# Note: this requires that Growl is running and the `growlnotify` command line tool is installed in $PATH
USE_GROWL='yes'


####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
#		You shouldn't _have_ to edit anything below this line
#
#		HOWEVER be sure to read the 'Quit app if running' section below!
#

	# edit if needed
PATH="/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/opt/X11/bin:/bin"

	# if you would like fewer diagnostic messages, set VERBOSE=no instead of
	# VERBOSE='yes'
VERBOSE='yes'

NAME="$0:t:r"

# !! APPDIR= must be set above this line!!
	APPPATH="$APPDIR/XLD.app"
		APPNAME="$APPPATH:t:r"

	# Home page: http://tmkk.undo.jp/xld/index_e.html
	# Sparkle Feed: http://xld.googlecode.com/svn/appcast/xld-appcast_e.xml
# RSS='http://xld.googlecode.com/svn/appcast/xld-appcast_e.xml'	# This is old. Very old.
RSS='https://svn.code.sf.net/p/xld/code/appcast/xld-appcast_e.xml'

zmodload zsh/datetime

# TS = time stamp
ts () { strftime %Y-%m-%d--%H.%M.%S "$EPOCHSECONDS" }

####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
#		Check installed version vs newest available
#

LATEST_VERSION=$(curl -sfL "$RSS" | fgrep 'sparkle:shortVersionString' | sed 's#.*parkle:shortVersionString="##g; s#".*##g')

INSTALLED_VERSION=$(fgrep -A1 CFBundleShortVersionString "${APPPATH}/Contents/Info.plist" 2>/dev/null | tr -dc "[0-9]\.")

if [[ "$INSTALLED_VERSION" == "$LATEST_VERSION" ]]
then
		[[ "$VERBOSE" == "yes" ]] &&  echo "	$NAME: $APPPATH is up to date at `ts` (Version $INSTALLED_VERSION)"

		exit 0
fi

####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
#		Download the file, if needed
#

cd "$DL_DIR"

URL=$(curl -sfL "$RSS" | tr '"' '\012' | egrep '^http.*\.dmg$' | head -1)

FILENAME="$URL:t"

if [[ ! -e "$FILENAME" ]]
then
		curl --progress-bar --fail --location --output "$FILENAME" "$URL"
fi

####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
#		Mount the DMG
#

[[ "$VERBOSE" == "yes" ]] &&  echo "	$NAME: attempting to mount $FILENAME at `ts`"

## Is there a EULA on the DMG? If so, use 'hdid'. Otherwise, use hdiutil
# MNTPNT=$(echo -n "Y" | hdid -plist "$FILENAME" 2>/dev/null | fgrep '/Volumes/' | sed 's#</string>##g ; s#.*<string>##g')

MNTPNT=$(hdiutil attach -nobrowse -plist "$FILENAME" 2>/dev/null \
	| fgrep -A 1 '<key>mount-point</key>' \
	| tail -1 \
	| sed 's#</string>.*##g ; s#.*<string>##g')

if [[ "$MNTPNT" == "" ]]
then
		echo "$NAME: \$MNTPNT	is empty"
		exit 1
fi

if [[ ! -d "$MNTPNT" ]]
then
		echo "$NAME: $MNTPNT is not a directory"

		exit 1
fi

####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
#		Quit app if running
#

#
#	WARNING: by default, the script will quit the app if it is running.
#		If you want to change that, uncomment these lines and the script will exit
#		immediately if the app is running. SAVE YOUR WORK BEFORE YOU GO TO BED.
#
# PID=`ps cx | awk -F' ' '/ ${APPNAME}$/{print $1}'`
#
# if [ "$PID" != "" ]
# then
# 		echo "$NAME: $APPNAME is currently running. Please quit and run this script again.
# 		exit 1
# fi


getpid () {

	PID=`ps cx | awk -F' ' '/ ${APPNAME}$/{print $1}'`
}

getpid	# run it once to set $PID

COUNT=0

WAS_RUNNING=no

while [ "$PID" != "" ]
do

		WAS_RUNNING=yes

			# If it's running, we'll loop around trying to get it to quit

		((COUNT++))

		[[ "$VERBOSE" == "yes" ]] &&  echo "	$NAME: $APPNAME ($PID) is running at `ts`"

		if [ "$COUNT" -gt "10" ]
		then
					# if we loop more than 10 times, quit

				[[ "$VERBOSE" == "yes" ]] &&  echo "	$NAME: $APPNAME failed to quit after $COUNT tries at `ts`"
				exit 1

		elif [ "$COUNT" -gt "5" ]
		then
					# if we loop more than 5 times, go for `kill`
				kill -TERM "$PID"

		elif [ "$COUNT" -gt "3" ]
		then
					# if we loop 3 times and it's still running, tell it to quit using AppleScript

				osascript -e "tell application \"$APPNAME\" to quit"
		fi

		sleep 5	# give it a chance to actually quit

		getpid	# check to the PID again

done
#
#		End 'QUIT' section
#
#
####|####|####|####|####|####|####|####|####|####|####|####|####|####|####

####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
#		Move existing version to the trash
#

if [[ -d "$APPPATH" ]]
then
		SHORT="$APPPATH:t:r"

		mv -vf "$APPPATH" "$TRASH/$SHORT.$INSTALLED_VERSION.app"
fi

####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
#		install via ditto
#

[[ "$VERBOSE" == "yes" ]] &&  echo "	$NAME: copying $MNTPNT/$APPPATH:t to $APPDIR/$APPPATH:t at `ts`"

ditto -v "$MNTPNT/$APPPATH:t" "$APPDIR/$APPPATH:t"

EXIT="$?"

if [[ "$EXIT" == "0" ]]
then

		[[ "$VERBOSE" == "yes" ]] &&  echo "	$NAME: SUCCESS installing $APPDIR/$APPPATH:t via ditto at `ts`"
else
		# failed
		echo "$NAME: ditto failed at `ts`"

		exit 1
fi

####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
#		Unmount DMG
#


if [[ -d "$MNTPNT" ]]
then

	[[ "$VERBOSE" == "yes" ]] &&  echo "	$NAME: trying to eject $MNTPNT:"

	diskutil eject "$MNTPNT"

fi

####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
#		Move $FILENAME to ~/.Trash/. That way we'll know it was installed
#		so we don't manually install it too, but if we do need it for
#		something (i.e. to copy to another computer without downloading it
#		again) we'll still have it accessible.
#

mv -f "$FILENAME" "$TRASH" && [[ "$VERBOSE" == "yes" ]] && echo "	$NAME: Moved $FILENAME to $TRASH"

####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
#		Send Growl Notification
#
if [[ "$USE_GROWL" = "yes" ]]
then

	GROWL_PID=$(ps cx | awk -F' ' '/ Growl$/{print $1}')

	if [[ "$GROWL_PID" != "" ]]
	then
		if (( $+commands[growlnotify] ))
		then
			growlnotify --sticky --message "Upgraded to version $LATEST_VERSION" --appIcon "XLD" --identifier "$NAME" "$NAME"

		fi # Growlnotify is installed

	fi # Growl is running

fi # USE_GROWL is YES

[[ "$VERBOSE" == "yes" ]] &&  echo "$NAME Successfully installed/updated at `ts`"

####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
#		Restart the app IFF it was running and we caused it to quit
#

if [ "$WAS_RUNNING" = "yes" ]
then
		# If the app was running and we made it quit, restart it now

		[[ "$VERBOSE" == "yes" ]] &&  echo "	$NAME: launching $APPPATH at `ts`"

		open "$APPPATH" || exit 1
fi


exit
#
#EOF
