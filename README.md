# Lpzrobots installation script

Here you find a small number of unofficial installation-scripts for the [lpzrobots](http://robot.informatik.uni-leipzig.de/software/) environment.

The script is a fancy way of doing the following in order. It will check if all dependencies are installed and install the program to `/home/YOUR-USERNAME/bin`:

	mkdir LpzRobots
	cd LpzRobots
	wget https://github.com/georgmartius/lpzrobots/archive/master.zip
	unzip master.zip
	cd lpzrobots-master
	
	# only if you have not installed all packages
	sudo apt-get update
	sudo apt-get install g++ make automake libtool xutils-dev m4 libreadline-dev libgsl0-dev \
	libglu-dev libgl1-mesa-dev freeglut3-dev libopenscenegraph-dev libqt4-dev libqt4-opengl \
	libqt4-opengl-dev qt4-qmake libqt4-qt3support gnuplot gnuplot-x11 libncurses5-dev
	
	make
	make all # this is where the magic happens, all credit goes to the lpzrobots-team

At the end the script checks if the installation was successful by starting one of the examples included with the lpzrobots-files.

## Usage

1. Download the zip-archive or clone the repository to your hard-drive
2. Use `chmod +x install-YOURDISTRO.sh` to make the script executable if it is not already
3. Run `./install-YOURDISTRO.sh` (you will need root permissions if there are uninstalled dependencies)
4. Follow the instructions

## ToDos

* scripts for other distributions

## License and Sources

* Files are provided by the lpzrobots-team: https://github.com/georgmartius/lpzrobots
* Sources for most commands used: user [verdooft](https://forum.ubuntuusers.de/topic/e-paket-guilogger-kann-nicht-gefunden-werden/) and [Leon Bonde Larsen](http://manoonpong.com/MOROCO/lpz_guide.txt)

Code is released under the [MIT-License](https://github.com/Larsg7/lpzrobots-install/blob/master/LICENSE.md).
