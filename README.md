# au (Automatically Update) XLD

## Why?

[XLD] -- a lossless audio decoder for Mac OS X --  is frequently updated, which means that there are new versions to download frequently. Although the app has [Sparkle] support, that still involves an interruption.

Rather than have to wait for that to happen when I'm ready to do something, I would rather have my apps update themselves automatically overnight when I am not using them, so I don't have to worry about dealing with updates myself.

## What?

The automatic upgrade process is handled by two parts:

* [au-xld.sh]: a shell script which should be installed to somewhere in your $PATH (I recommend `/usr/local/bin/`. Make sure it is executable (`chmod 755 /usr/local/bin/au-xld.sh`) before you try to run it!

* [com.tjluoma.au-xld.plist]: a launchd plist which must be installed to `$HOME/Library/LaunchAgents/`


## How?

The [au-xld.sh] shell script looks at the [Sparkle feed] for the latest version of the app, and then compares it to the currently installed version.

If the app is already up to date, `au-xld.sh` will exit.

If the app is outdated, a new DMG will be downloaded, mounted, installed, and the DMG ejected.

If an older version of the app was found, it will be moved to the Trash (and the version number will be added to the filename in case you want to revert to a previous version).

(**Nerd Note:** the comparison is made between the "sparkle:shortVersionString" and the app's "CFBundleShortVersionString". If they are different, then the script will download and install the version from the website.)

## When?

By default, the [au-xld.sh] script will run every day at 6:00 a.m. (local time) and anytime you log into the computer.

You can change this by editing the `StartCalendarInterval` setting in [com.tjluoma.au-xld.plist]. (Note: I use and recommend [LaunchControl] for interacting with `launchd`.)


## WARNING:

Please Note: **If the app is running and needs to be updated, it will automatically be quit and restarted after the upgrade is done.**

If you would like to change that behavior, I have provided simple instructions in the script.

My assumption is that you will not be working in XLD at 6:00 a.m. and that any open files will have been saved.

YOU ASSUME 100% OF ANY AND ALL RISK, LIABILITY, HARDSHIP, INCONVENIENCE and/or IRRITATION BROUGHT ABOUT BY USING THIS SCRIPT.

## Troubleshooting

* Look in `/tmp/au-xld-stdout.txt` and `/tmp/au-xld-stderr.txt` to see if there are any messages in either file.

* Did you make [au-xld.sh] executable? Is it in the $PATH set in [com.tjluoma.au-xld.plist]?

* Did you put [com.tjluoma.au-xld.plist] in ~/Library/LaunchAgents ?

* Have you logged out and/or rebooted since you installed the files?


## How to install ##

1. Download [install-au-xld.sh] 
2. chmod 755 install-au-xld.sh
3. ./install-au-xld.sh
4. Follow prompts

## How to Uninstall

1. Delete the [au-xld.sh] script and the [com.tjluoma.au-xld.plist] file from ~/Library/LaunchAgents

2. Reboot


<!-- Reference Links -->

[Sparkle feed]: http://xld.googlecode.com/svn/appcast/xld-appcast_e.xml

[Sparkle]: http://sparkle.andymatuschak.org/

[XLD]: http://tmkk.undo.jp/xld/index_e.html

[LaunchControl]: http://www.soma-zone.com/LaunchControl/

[com.tjluoma.au-xld.plist]: https://github.com/tjluoma/au-xld/blob/master/com.tjluoma.au-xld.plist

[au-xld.sh]: https://github.com/tjluoma/au-xld/blob/master/au-xld.sh

[install-au-xld.sh]: https://github.com/tjluoma/au-xld/blob/master/install-au-xld.sh
