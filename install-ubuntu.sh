#!/bin/bash

# this script downloads and installs
# 	the lpzrobots-environment
# 	all necessary packages for compiling and building it
#
# more information and the license used can be found here: 
# https://github.com/Larsg7/lpzrobots-install


# first clear the screen
clear

# display some information about the program to the user
printf "\nThis script will download and install the lpzrobots-environment for you.\n\n"
printf "It has been tested on Ubuntu 14.04. Default values are in '[]' and/or capitalized, \
just press ENTER to use them.\n\n"
printf "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND.\n"


# small function to check exit-status ToDo: show last command
function chExitStatus {
	if [[ ! $? -eq 0 ]]; then
	printf "\nSomething went wrong while running the last command. - ABORT\n"
	exit 1
fi
}

# ask the user in which directory the files should go
while [[ true ]]; do
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


# move into the directory the user has specified
cd $location

# make directory LpzRobots (exits with error if directory already exists)
mkdir LpzRobots

# move into the newly created directory
cd LpzRobots

printf "Downloading files from github.\n\n"
wget https://github.com/georgmartius/lpzrobots/archive/master.zip

printf "Unzipping content.\n\n"
unzip master.zip

# check if directory exists
if [[ ! -e lpzrobots-master ]]; then
	printf "\nSorry, something went wrong downloading or unzipping the files \
('lpzrobots-master'-directory does not exist). - ABORT\n"
	exit 1
fi

# move into the correct directory
cd lpzrobots-master

printf "\nMaking sure essentials are installed.\n"
sudo apt-get update
# no checking here because "apt-get update" can produce non-critical errors
# e.g. non-critical repository not found

sudo apt-get install build-essential

# check if packages "build-essentials" are installed correctly
chExitStatus

printf "Installing necessary packages for compiling.\n\n"
sudo apt-get install g++ make automake libtool xutils-dev m4 libreadline-dev libgsl0-dev \
libglu-dev libgl1-mesa-dev freeglut3-dev libopenscenegraph-dev libqt4-dev libqt4-opengl \
libqt4-opengl-dev qt4-qmake libqt4-qt3support gnuplot gnuplot-x11 libncurses5-dev

# check if all packages were installed correctly
chExitStatus

printf "\nAll packages necessary for compiling are now installed.\n"

# ask user if they want to continue with the compile process
while true; do
printf "The next command will compile the program, it will take a long time to finish. \nDo you want to continue? (write no/yes)\n"

read ans

# again check answer
if [[ $ans == "no" ]]; then
	echo "Exiting."
	exit 0
elif [[ $ans == "yes" ]]; then
	printf "OK, continuing.\n\n"
	break
else
	printf "Sorry, did not catch that!\n\n"
	continue
fi
done


printf "\nStarting the make-process.\n"	
make

wait

# check if make process was successful
chExitStatus

# start build-process
sudo make all

wait

# check if build process was successful
chExitStatus

# make symlink
sudo ln -sf ${location}/LpzRobots/lpzrobots-master/opende/ode/src/.libs/libode_dbl.so.1 /lib/libode_dbl.so.1

# show user success message (is also displayed if user cancels build-process)
printf "\nThat should be it, lpzrobots is now installed.\n"

while true; do
printf "Do you want to test if the program is installed correctly? [n/Y]"

read ans

# again check answer
if [[ $ans == "n" ]]; then
	printf "Ok, exiting. Have a nice day!\n"
	exit 0
elif [[ $ans == "Y" || $ans == "y" ]]; then
	break
else
	printf "Sorry, did not catch that!\n\n"
	continue
fi
done

printf "OK, the robot-examble 'basic' will be compiled and started. If there is no error message and a window with a basic robot-simulation opens everything works.\nPlease press ENTER.\n"

read ans

cd ${location}/LpzRobots/lpzrobots-master/ode_robots/examples/basic

chExitStatus

make

chExitStatus

${location}/LpzRobots/lpzrobots-master/ode_robots/examples/basic/start

wait 

printf "Have a nice day!\n"
exit 0
