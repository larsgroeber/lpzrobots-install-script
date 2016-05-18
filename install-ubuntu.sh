#!/bin/bash


# This script downloads and installs the lpzrobots-environment and all necessary 
# packages for compiling, building and running it.
#
# more information about the script and the license used can be found here: 
# https://github.com/Larsg7/lpzrobots-install-script


# small function to check exit-status
function chExitStatus {
	if [[ ! $? -eq 0 ]]; then
	printf "\nSomething went wrong while running the last command. - Exiting\n"
	exit 1
fi
}

function installPackages {
	printf "\nMaking sure essentials are installed...\n"
	sudo apt-get -qq update # quiet-mode
	# no checking here because "apt-get update" can produce non-critical errors
	# e.g. non-critical repository not found

	sudo apt-get install build-essential

	# check if packages "build-essentials" are installed correctly
	chExitStatus

	printf "\nInstalling necessary packages for compiling...\n"
	sleep 2
	sudo apt-get install g++ make automake libtool xutils-dev m4 libreadline-dev libgsl0-dev \
	libglu-dev libgl1-mesa-dev freeglut3-dev libopenscenegraph-dev libqt4-dev libqt4-opengl \
	libqt4-opengl-dev qt4-qmake libqt4-qt3support gnuplot gnuplot-x11 libncurses5-dev

	# check if all packages were installed correctly
	chExitStatus

	printf "\nAll packages necessary for compiling are now installed.\n"
}

function makeProgram {
	# call with location of files as first argument!

	printf "\nStarting the make-process.\n"	
	sleep 1

	# make symlink (otherwise there will be errors)
	sudo ln -sf ${1}/LpzRobots/lpzrobots-master/opende/ode/src/.libs/libode_dbl.so.1 /lib/libode_dbl.so.1

	# start timer
	START=$(date +%s.%N)

	make

	wait

	# check if make process was successful
	chExitStatus

	# start make-process
	sudo make all

	wait

	# check if build process was successful
	chExitStatus

	# end timer
	END=$(date +%s.%N)

	# calculate difference
	DIFF=$(echo "($END - $START)" | bc)

	# show user success message (is also displayed if user cancels build-process)
	printf "\nLpzrobots should now be installed (the make-process took $DIFF seconds).\n"
}

function getFiles {
	# call with location of files as first argument!

	# move into the directory the user has specified
	cd $1

	# make directory LpzRobots (exits with error if directory already exists)
	mkdir LpzRobots

	# move into the newly created directory
	cd LpzRobots

	printf "Downloading files from github...\n\n"
	wget --quiet https://github.com/georgmartius/lpzrobots/archive/master.zip

	chExitStatus

	printf "Unzipping content...\n\n"
	unzip -q master.zip

	# check if directory exists
	if [[ ! -e lpzrobots-master ]]; then
		printf "\nSorry, something went wrong downloading or unzipping the files \
	('lpzrobots-master'-directory does not exist). - ABORT\n"
		exit 1
	fi

	# move into the correct directory
	cd lpzrobots-master
}

function testInstall {
	# call with location of files as first argument!

	printf "\nOk, the robot-example 'basic' will be compiled and started. If there is no error message and a window \
	with a basic robot-simulation opens everything works fine.\nPlease press ENTER.\n"

	# wait for user to press ENTER
	read ans

	# enter basic-example directory
	cd ${1}/LpzRobots/lpzrobots-master/ode_robots/examples/basic

	chExitStatus

	# compile the example
	make

	chExitStatus

	# start the example
	${1}/LpzRobots/lpzrobots-master/ode_robots/examples/basic/start

	# wait for simulation to end
	wait 

	chExitStatus
}

function cleanUp {
	printf "\nCleaning up...\n"
	rm ${1}/LpzRobots/master.zip
}

trap "printf '\nExiting...\n'; exit 0" INT TERM


######	Initial setup  ######

# first clear the screen
clear

# display some information about the program to the user
printf "\nThis script will download and install the lpzrobots-environment for you.\n\n"
printf "It has been tested on Ubuntu 14.04. Default values are in '[]' and/or capitalized, \
just press ENTER to use them.\n\n"
printf "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND.\n"

# ask the user in which directory the files should go
while true; do
printf "\nIn which directory should the program be downloaded and compiled? ('/LpzRobots' \
will be added to the end of the path, don't use '~') [/home/${USER}/Downloads]\n"

# read the answer from the command line
read location

# if location is empty take default value otherwise just keep the input
if [[ -z $location ]]; then
	location="/home/${USER}/Downloads"
fi

# check if $location exists, is a directory and if we have read/write access
if [[ ! -d $location || ! -w $location ]]; then
	printf "Directory does not exist or you do not have read/write-access! \nChoose another one.\n"
	continue
fi

# ask user for confirmation
printf "\nThe lpzrobots-files will now be downloaded into the directory ${location}/LpzRobots.\nIs this OK? [n/Y]\n"

read ans

# check answer
if [[ $ans == "n" ]]; then
	echo
	continue
elif [[ $ans == "" || $ans == "Y" ]]; then
	printf "OK, continuing.\n"
	break
else
	printf "Sorry, did not catch that!\n\n"
	continue
fi

done

# set up the trap for the clean up process
trap "cleanUp $location" EXIT

######  Downloading the files ######

getFiles $location


######  Installing packages  ######

installPackages


######  Build/compile program  ######

# ask user if they want to continue with the compile-process
while true; do
printf "The next command will compile the program, it will take a long time to finish. \nDo you want to continue? (type no/yes)\n"

read ans

# again check answer
if [[ $ans == "no" ]]; then
	echo "Exiting."
	exit 0
elif [[ $ans == "yes" ]]; then
	printf "\nOK, continuing.\n\n"
	makeProgram $location
	break
else
	printf "Sorry, did not catch that!\n\n"
	continue
fi
done


######  Check installation  ######

while true; do
printf "\nDo you want to test if the program is installed correctly? [n/Y]"

read ans

# again check answer
if [[ $ans == "n" ]]; then
	break
elif [[ $ans == "Y" || $ans == "y" || -z $ans ]]; then
	testInstall $location
	break
else
	printf "Sorry, did not catch that!\n\n"
	continue
fi
done


printf "\nThat's it! Have a nice day.\n"


######  End  ######


exit 0
