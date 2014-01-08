#!/bin/bash

## Simple exec script for spindle
## Needs spindle folder to be installed (or linked) at ~/bin/spindle
## If you link spindle don't link the build folder and other writable 
## folders you don't want to share
clear 

alias rm='rm -I'

if [ -d ~/bin/spindle ] ; then
        export PATH="~/bin/spindle:$PATH"
        cd ~/bin/spindle
else
        echo "Have not found spindle at ~/bin/spindle \
        Install or link spindle and try again."
        exit 1
fi


## Script Functions ###################

waitforit(){
    echo && echo
    read -p 'Press [Enter] to continue or [Ctrl]+[C] to Quit: ' "EXIT"
}

ShowMenu(){
    ## Set needed variable
    CONTINUE='false'
    
    ## Show the menu in a loop
    while [ $CONTINUE != 'true' ] ; do

    ## Show Menu Header
    echo
    echo '                    Spindle CLI Menu, by: Socialdefect'
    echo ''
    echo '    0) Read Spindle manual (press "q" to exit manual)
           --------------------
    1) Setup Spindle chroot		11) Clean Spindle chroot
    111) Open shell in Spindle chroot
    2) Downgrade system Qemu		22) Downgrade Qemu in chroot
    3) Run Wheezy Stage0		33) Run Wheezy Stage0 in chroot
    4) Run Wheezy Stage1		44) Run Wheezy Stage1 in chroot
    5) Run Wheezy Stage2		55) Run Wheezy Stage2 in chroot
    6) Run Wheezy Stage3		66) Run Wheezy Stage3 in chroot
    7) Run Wheezy Stage4 LXDE		77) Run Wheezy Stage4 LXDE in chroot
    8) Run Wheezy Stage4 LXDE EDU	88) Run Wheezy Stage4 LXDE EDU in chroot
    9) Run Custom Stage4		99) Run Custom Stage4 in chroot
           ------------
     a) Build bootable stage4 image
     b) Build bootable stage3 image
     c) Build bootable stage4 image in chroot
     d) Build bootable stage3 image in chroot
           ------------
     x) Exit Spindle Menu'
    echo ""
    read -p 'Make a selection: ' SelectTask

    case "$SelectTask" in
	0)
	less ~/bin/spindle/README.mkd
	;;
        1)
        sudo setup_spindle_environment my_spindle_chroot
        sudo modprobe nbd max_part=16
        echo
        sudo rm -rfv my_spindle_chroot
        ;;
        111)
        clear
        echo 'Entering Spindle Chroot, type "exit" to return to the menu.'
        sleep 2
        schroot -c spindle
        ;;
        2)
        downgrade_qemu
        ;;
        22)
        schroot -c spindle downgrade_qemu
        ;;
        3)
        wheezy-stage0
        ;;
        33)
        schroot -c spindle wheezy-stage0
        ;;
        4)
        wheezy-stage1
        ;;
        44)
        schroot -c spindle wheezy-stage1
        ;;
        5)
        wheezy-stage2
        ;;
        55)
        schroot -c spindle wheezy-stage2
        ;;
        6)
        wheezy-stage3
        ;;
        66)
        schroot -c spindle wheezy-stage3
        ;;
        7)
        wheezy-stage4-lxde
        FILENAME="stage4-lxde"
        ;;
        77)
        schroot -c spindle wheezy-stage4-lxde
        FILENAME="stage4-lxde"
        ;;
        8)
        wheezy-stage4-lxde-edu
        FILENAME="stage4-lxde-edu"
        ;;
        88)
        schroot -c spindle wheezy-stage4-lxde-edu
        FILENAME="stage4-lxde-edu"
        ;;
        9)
        TRUE="1"
        while [ $TRUE != 0 ] ; do
	    clear
	    echo && echo "The stage4 is the final building stage which includes the applications \
	    you like to install on top of the base system. \
	    You can copy the included stage4 scripts as templates. \
	     \
	    If your custom stage4 is stored in ~/bin/spindle/my_stage4 you can enter my_stage4 here. \
	    If you have stored the script somewhere else please enter the full path." && echo
	    read -p 'Enter Stage4 Script: ' MY_STAGE4
	    if [ -f "$MY_STAGE4" ] ; then
		  echo "Found $MY_STAGE4 executable"
		  chmod +x "$MY_STAGE4"
		  "$MY_STAGE4"
		  TRUE="$?"
		  FILENAME=${MY_STAGE4##*/}
		  if [ "$TRUE" != 0 ] ; then
		      echo && echo 'The script returned an error. Please check what is wrong and try again.' && echo
		      waitforit
		  fi
	    else
		  echo "$MY_STAGE4 does not exist! \
		  Please create the file and try again!"
		  TRUE=1
		  exit 1
	    fi
	done
        ;;
        99)
        TRUE="1"
        while [ $TRUE != 0 ] ; do
	    clear
	    echo && echo "The stage4 is the final building stage which includes the applications \
	    you like to install on top of the base system. \
	    You can copy the included stage4 scripts as templates. \
	     \
	    If your custom stage4 is stored in ~/bin/spindle/my_stage4 you can enter my_stage4 here. \
	    If you have stored the script somewhere else please enter the full path." && echo
	    read -p 'Enter Stage4 Script: ' MY_STAGE4
	    if [ -f "$MY_STAGE4" ] ; then
		  echo "Found $MY_STAGE4 executable"
		  chmod +x "$MY_STAGE4"
		  sudo cp "$MY_STAGE4" my_spindle_chroot/
		  schroot -c spindle /"$MY_STAGE4"
		  TRUE="$?"
		  FILENAME=${MY_STAGE4##*/}
		  if [ "$TRUE" != 0 ] ; then
		      echo && echo 'The script returned an error. Please check what is wrong and try again.' && echo
		      waitforit
		  fi
	    else
		  echo "$MY_STAGE4 does not exist! \
		  Please create the file and try again!"
		  TRUE=1
		  exit 1
	    fi
	done
        ;;
        a)
        if [ -f out/"$FILENAME" ] ; then
	    helper export_image_for_release out/"$FILENAME".qed "$FILENAME".img
	else
	    echo 'Cannot find your stage4 build in out/, cannot build image...'
	fi
        ;;
        b)
        if [ -f out/"stage3" ] ; then
	    helper export_image_for_release out/"stage3".qed "stage3".img
	else
	    echo 'Cannot find your stage4 build in out/, cannot build image...'
	fi
        ;;
        c)
        schroot -c spindle helper export_image_for_release out/"$FILENAME".qed "$FILENAME".img
        ;;
        d)
        schroot -c spindle helper export_image_for_release out/"stage3".qed "stage3".img
        ;;
        e)
        echo 'Enter the filename for the stage you want to build an image for.
        the stage must have been successfuly build allready.'
        echo
        if [ -f out/stage3 ] ; then
	    echo 'Found stage3 build'
	else
	    echo 'No stage3 in out/'
	fi
	STAGE4_BUILDS=`ls out/*stage4*`
	for i in $STAGE4_BUILDS ; do
	    if [ -f out/$i ] ; then
		echo "Found stage4 build $i"
	    else
		echo 'No stage4 builds in out/'
	    fi
	done
	echo
	echo 'Enter filename '
        read -p 'Filename: ' FILENAME
        ;;
        x)
            echo ""
            exit 0
        ;;
        *)
        echo
        echo '  !!>  Syntax Terror.. Please enter a number that is actualy in the list!'
        sleep 3
        ;;
    esac
done
}


## Execute the main loop
ShowMenu

exit 0