#Install_Pritunl_ONLY

#!/bin/bash

#Without licenses - Only for study purposed
#Created by SyedMokhtar @https://www.facebook.com/syed.mokhtardahari
echo "SELAMAT SEJAHTERA"

clear

a="`netstat -i | cut -d' ' -f1 | grep eth0`";
b="`netstat -i | cut -d' ' -f1 | grep venet0:0`";

if [ "$a" == "eth0" ]; then
  ip="`/sbin/ifconfig eth0 | awk -F':| +' '/inet addr/{print $4}'`";
elif [ "$b" == "venet0:0" ]; then
  ip="`/sbin/ifconfig venet0:0 | awk -F':| +' '/inet addr/{print $4}'`";
fi

#Install the Pritunl
apt-get install -y sudo
apt-get install --reinstall software-properties-common
apt-get install -y python-software-properties
add-apt-repository -y ppa:pritunl
apt-get update; apt-get install pritunl

#Install the Mongodb
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
apt-get update
apt-get install -y mongodb-org
apt-get install -y mongodb-org=3.0.4 mongodb-org-server=3.0.4 mongodb-org-shell=3.0.4 mongodb-org-mongos=3.0.4 mongodb-org-tools=3.0.4
echo "mongodb-org hold" | sudo dpkg --set-selections
echo "mongodb-org-server hold" | sudo dpkg --set-selections
echo "mongodb-org-shell hold" | sudo dpkg --set-selections
echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
echo "mongodb-org-tools hold" | sudo dpkg --set-selections

sudo service mongod start
cd
rm ./Install_Pritunl_ONLY.sh

echo " "
echo "OPENVPN server set up has been completed"
echo " "
echo "Login into browser https://$ip:9700/ for Pritunl setup" 
echo "***************************************************"
echo " "
echo " "
#FOR removing the Mongodb
#sudo service mongod stop
#sudo apt-get purge mongodb-org*
#sudo rm -r /var/log/mongodb
#sudo rm -r /var/lib/mongodb
