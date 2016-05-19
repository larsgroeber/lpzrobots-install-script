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

	pkg=( g++ make automake libtool xutils-dev m4 libreadline-dev libgsl-dev \
	libglu1-mesa-dev libgl1-mesa-dev freeglut3-dev libopenscenegraph-dev libqt4-dev libqt4-opengl \
	libqt4-opengl-dev qt4-qmake libqt4-qt3support gnuplot gnuplot-x11 libncurses5-dev )

	toInstall=()

	for name in ${pkg[*]}; do
		printf "Checking if $name is installed..."
		if ! dpkg -s $name > /dev/null; then
			toInstall+=( $name )
			printf " - No\n"
			continue
		fi
		printf " - Ok\n"
	done

	if [[ -z '$toInstall' ]]; then
		printf "\nInstalling necessary packages for compiling...\n"
		sudo apt-get -qq update # quiet-mode

		sudo apt-get install ${toInstall[*]}

		chExitStatus

		printf "\nAll packages necessary for compiling are installed.\n"
	fi	
}

function makeProgram {
	# call with location of files as first argument!

	# replace installation location for easier install w/o sudo
	#sed -i "s/{1:-\/usr\/local}/{1:-\/home\/${USER}\/Documents}/g" createMakefile.conf.sh
	#sed -i "s/Please use either \/usr, \/usr\/local  or you home directory/Please use either \/home\/${USER}\/Documents or your home directory/g" createMakefile.conf.sh
	
	# taken directly form the createMakefile.conf.sh-File
	prefix="/home/$USER"
	export PATH=$prefix/bin:$PATH

	chExitStatus

	# taken directly form createMakefile.conf.sh
	echo -e "# configuration file for lpzrobots (automatically generated!)\n\
	# Where to install the simulator and utils"  > Makefile.conf
	echo "PREFIX=$prefix" >> Makefile.conf
	echo -e "\n# user or developement installation\n\
	# Options:\n\
	#  DEVEL: only install the utility functions,\n\
	#   which is useful for development on the simulator\n\
	#  USER: install also the ode_robots and selforg libaries and include files\n\
	#   this is recommended for users" >> Makefile.conf
	echo "TYPE=DEVEL" >> Makefile.conf

	echo "// Automatically generated file! Use make conf in lpzrobots." > ode_robots/install_prefix.conf
	echo "#define PREFIX \"$prefix\"" >> ode_robots/install_prefix.conf


	printf "\nStarting the make-process.\n"	
	sleep 1

	# start timer
	START=$(date +%s.%N)

	# start make-process
	make all

	# check if build process was successful
	chExitStatus

	# end timer
	END=$(date +%s.%N)

	# make symlink (otherwise there will be errors)
	#sudo ln -sf ${1}/LpzRobots/lpzrobots-master/opende/ode/src/.libs/libode_dbl.so.1 /lib/libode_dbl.so.1

	# calculate difference
	DIFF=$(echo "($END - $START)" | bc)

	# show user success message (is also displayed if user cancels build-process)
	printf "\nLpzrobots should now be installed (the make-process took $DIFF seconds).\n"
}

function getFiles {
	# call with location of files as first argument!

	# move into the directory the user has specified
	cd $1

	# make directory LpzRobots
	if [[ ! -d LpzRobots ]]; then mkdir LpzRobots; fi

	# move into the newly created directory
	cd LpzRobots

	printf "Getting files from github...\n"
	wget --quiet https://github.com/georgmartius/lpzrobots/archive/master.zip

	chExitStatus

	printf "Unzipping content...\n"
	unzip -q master.zip

	# check if directory exists
	if [[ ! -e lpzrobots-master ]]; then
		printf "\nSorry, something went wrong downloading or unzipping the files \
	('lpzrobots-master'-directory does not exist). - Exiting\n"
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
	if [[ -e ${1}/LpzRobots/master.zip ]];then rm ${1}/LpzRobots/master.zip; fi
}

trap "printf '\nExiting...\n'; exit 1" INT TERM


######	Initial setup  ######

# first clear the screen
clear

# display some information about the program to the user
printf "\nThis script will download and install the lpzrobots-environment for you.\n"
printf "It has been tested on Ubuntu 14.04 and 16.04. Default values are in '[]' and/or capitalized, \
just press ENTER to use them.\n"
printf "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND.\n"

# ask the user in which directory the files should go
while :
do
	defLoc="/home/${USER}"
	printf "\nIn which directory should the program be downloaded and compiled? ('/LpzRobots' \
	will be added to the end of the path, don't use '~') [$defLoc]\n"

	# read the answer from the command line
	read location

	# if location is empty take default value otherwise just keep the input
	if [[ -z $location ]]; then	location=$defLoc; fi

	# check if $location exists, is a directory and if we have read/write access
	if [[ ! -d $location || ! -w $location ]]; then
		printf "Directory does not exist or you do not have read/write-access! \nChoose another one.\n"
		continue
	else
		printf "\nThe lpzrobots-files will now be downloaded into the directory ${location}/LpzRobots.\n"
		break
	fi
done

# set up the trap for the clean up process
trap "cleanUp $location" EXIT

######  Downloading the files ######

getFiles $location


######  Installing packages  ######

installPackages


######  Build/compile program  ######

makeProgram $location


######  Check installation  ######

printf "\nDo you want to test if the program is installed correctly? [n/Y]"

read ans

# again check answer
if [[ $ans == "Y" || $ans == "y" || -z $ans ]]; then testInstall $location; fi

printf "\nThat's it! Have a nice day.\n"


######  End  ######


exit 0