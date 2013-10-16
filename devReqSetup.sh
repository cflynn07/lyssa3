#!/bin/sh

line="-------------------------------------------------"
bigline="====================================================="
squigline="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
slashline="/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/"
msg=""
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

red="\033[0;31m"
green="\033[0;32m"
white="\033[0;37m"
blue="\033[0;34m"
h1(){
  echo "$red$bigline"
  echo $slashline
  echo $squigline
  echo "WELCOME TO CASEY'S DEV ENVIRONMENT INSTALLER EMPORIUM"
  echo $squigline
  echo $slashline
  echo $bigline
  echo $white
}
h2(){
  echo "\n"
  echo "$green$line"
  echo $msg
  echo $line
  echo $white
}

h1

cd /tmp

#Install VirtualBox
msg="INSTALLING VirtualBox..."
h2
curl http://download.virtualbox.org/virtualbox/4.2.18/VirtualBox-4.2.18-88780-OSX.dmg --output virtuabox.dmg -L
hdiutil attach ./virtuabox.dmg
sudo installer -pkg /Volumes/VirtualBox/VirtualBox.pkg -target /Volumes/Macintosh\ HD
hdiutil detach /Volumes/VirtualBox

#Install Vagrant
msg="INSTALLING Vagrant..."
h2
curl http://files.vagrantup.com/packages/b12c7e8814171c1295ef82416ffe51e8a168a244/Vagrant-1.3.1.dmg --output vagrant.dmg -L
hdiutil attach ./vagrant.dmg
sudo installer -pkg /Volumes/Vagrant/Vagrant.pkg -target /Volumes/Macintosh\ HD
hdiutil detach /Volumes/Vagrant

#Install Vagrant plugins
msg="INSTALLING Vagrant Plugins..."
h2
vagrant plugin install vagrant-hostmanager

msg="Downloading a vanilla 64bit Ubuntu 12.04 linux distrobution for your development VM Environment..."
h2
vagrant box add precise64 http://files.vagrantup.com/precise64.box

#Cloning the git repository into your Desktop...
msg="Done with setup. To start the application:\nvagrant up"
h2
#vagrant up
