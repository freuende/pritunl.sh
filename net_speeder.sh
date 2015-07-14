#!/bin/bash
# Set Linux PATH Environment Variables
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#Update your OS
apt-get --yes --force-yes install sudo
sudo apt-get --yes --force-yes update
sudo apt-get --yes --force-yes install --reinstall software-properties-common
sudo apt-get --yes --force-yes install python-software-properties
sudo apt-get --yes --force-yes install libnet1
sudo apt-get --yes --force-yes install libpcap0.8
sudo apt-get --yes --force-yes install libnet1-dev
sudo apt-get --yes --force-yes install libpcap0.8-dev
sudo apt-get --yes --force-yes install apt-utils

# Check If You Are Root
if [ $(id -u) != "0" ]; then
	clear
	echo -e "Error: You must be root to run this script!"
	exit 1
fi
wget http://net-speeder.googlecode.com/files/net_speeder-v0.1.tar.gz -O -|tar xz
cd net_speeder
if [ -f /proc/user_beancounters ] || [ -d /proc/bc ]; then
	sh build.sh -DCOOKED
	INTERFACE=venet0
else
	sh build.sh
	INTERFACE=eth0
fi
NS_PATH=/usr/local/net_speeder
mkdir -p $NS_PATH
cp -Rf net_speeder $NS_PATH
echo -e "net_speeder installed."
echo -e "Usage: nohup ${NS_PATH}/net_speeder $INTERFACE "ip" >/dev/null 2>&1 &"

exit 0

