#!/bin/bash

#This script create and compile by SyedMokhtar #https://www.facebook.com/syed.mokhtardahari

clear

#echo " "
#echo "*****************************************************"
echo "WELCOME TO THE PRITUNL & MONGODB INSTALLATION SCRIPT FOR UBUNTU 14.04 x64"
#echo "-----------------------------------------------------"
#echo " "
#echo " "
#echo " "
#echo "Please enter a user name for Squid:"
#read u
#echo " "
#echo "Please enter a password (will be shown in plain text while typing):"
#read p
#echo " "

clear

a="`netstat -i | cut -d' ' -f1 | grep eth0`";
b="`netstat -i | cut -d' ' -f1 | grep venet0:0`";

if [ "$a" == "eth0" ]; then
  ip="`/sbin/ifconfig eth0 | awk -F':| +' '/inet addr/{print $4}'`";
elif [ "$b" == "venet0:0" ]; then
  ip="`/sbin/ifconfig venet0:0 | awk -F':| +' '/inet addr/{print $4}'`";
fi

cd
#Install the Pritunl
apt-get --yes --force-yes install sudo
sudo apt-get --yes --force-yes update
sudo apt-get --yes --force-yes upgrade
sudo apt-get --yes --force-yes install --reinstall software-properties-common
sudo apt-get --yes --force-yes install python-software-properties
sudo apt-get --yes --force-yes install nano
sudo apt-get --yes --force-yes install libnet1
sudo apt-get --yes --force-yes install libpcap0.8
sudo apt-get --yes --force-yes install libnet1-dev
sudo apt-get --yes --force-yes install libpcap0.8-dev
sudo apt-get --yes --force-yes install apt-utils
sudo add-apt-repository --yes --force-yes ppa:pritunl
sudo apt-get --yes --force-yes install pritunl

sudo service pritunl start
cd

#Install the Mongodb
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.0.list
sudo apt-get --yes --force-yes update
sudo apt-get --yes --force-yes upgrade
sudo apt-get --yes --force-yes install -y mongodb-org
sudo apt-get --yes --force-yes install -y mongodb-org=3.0.4 mongodb-org-server=3.0.4 mongodb-org-shell=3.0.4 mongodb-org-mongos=3.0.4 mongodb-org-tools=3.0.4
echo "mongodb-org hold" | sudo dpkg --set-selections
echo "mongodb-org-server hold" | sudo dpkg --set-selections
echo "mongodb-org-shell hold" | sudo dpkg --set-selections
echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
echo "mongodb-org-tools hold" | sudo dpkg --set-selections

sudo service mongod start
cd

#Install Net speeder
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

cd
sudo apt-get --yes --force-yes install apache2-utils
sudo apt-get --yes --force-yes install squid3

rm /etc/squid3/squid.conf

cat > /etc/squid3/squid.conf <<END
acl ip1 myip $ip
tcp_outgoing_address $ip ip1

visible_hostname ProxySyed
http_port 56665
http_port 7890
icp_port 3130
dns_nameservers 8.8.4.4 8.8.8.8
forwarded_for off

hierarchy_stoplist cgi-bin ?
coredump_dir /var/spool/squid3
cache_dir ufs /var/spool/squid3 16384 16 256
error_directory /usr/share/squid3/errors/templates/
cache deny all

#acl manager proto cache_object
acl localnet src 10.0.0.0/8
acl localnet src 172.16.0.0/12
acl localnet src 192.168.0.0/16
acl localhost src 127.0.0.1/32

acl SSL_ports port 443
acl Safe_ports port 80        # http
acl Safe_ports port 21        # ftp
acl Safe_ports port 443        # https
acl Safe_ports port 1025-65535    # unregistered ports
acl Safe_ports port 280        # http-mgmt
acl Safe_ports port 488        # gss-http
acl Safe_ports port 591        # filemaker
acl Safe_ports port 777        # multiling http
acl purge method PURGE
acl CONNECT method CONNECT
http_access allow all

icp_access deny all
htcp_access deny all
http_access allow localnet
http_access allow localhost
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports

refresh_pattern ^ftp:        1440    20%    10080
refresh_pattern ^gopher:    1440    0%    1440
refresh_pattern -i (/cgi-bin/|\?) 0    0%    0
refresh_pattern .        0    20%    4320

#control IP
#acl control_ip dst 104.238.150.62-104.238.150.62/255.255.255.255 #This will be your client ip
#http_access allow control_ip #to allow the gatekeeper

# Request Headers Forcing
request_header_access Allow allow all
request_header_access Authorization allow all
request_header_access WWW-Authenticate allow all
request_header_access Proxy-Authorization allow all
request_header_access Proxy-Authenticate allow all
request_header_access Cache-Control allow all
request_header_access Content-Encoding allow all
request_header_access Content-Length allow all
request_header_access Content-Type allow all
request_header_access Date allow all
request_header_access Expires allow all
request_header_access Host allow all
request_header_access If-Modified-Since allow all
request_header_access Last-Modified allow all
request_header_access Location allow all
request_header_access Pragma allow all
request_header_access Accept allow all
request_header_access Accept-Charset allow all
request_header_access Accept-Encoding allow all
request_header_access Accept-Language allow all
request_header_access Content-Language allow all
request_header_access Mime-Version allow all
request_header_access Retry-After allow all
request_header_access Title allow all
request_header_access Connection allow all
request_header_access Proxy-Connection allow all
request_header_access User-Agent allow all
request_header_access Cookie allow all
request_header_access All deny all

# Response Headers Spoofing

reply_header_access Via deny all
reply_header_access X-Cache deny all
reply_header_access X-Cache-Lookup deny all
END
sudo service squid3 stop
squid3 -z

#htpasswd -b -c /etc/squid3/squid_passwd $u $p
sudo service squid3 restart

cd
netstat -atp tcp | grep -i "listen"
squid3 -NCd1
clear

echo " "
echo "***************************************************"
echo "Squid proxy server set up has been completed"
echo " "
echo "You can access your proxy server at $ip"
echo "on port 7890 with user name $u"
cat /etc/squid3/squid.conf |grep ^http_port
echo " "
echo "OPENVPN server set up has been completed"
echo " "
echo "Login into browser https://$ip:9700/ for Pritunl setup" 
echo "***************************************************"
echo " "
echo " "
rm ./Install_Pritunl.sh
echo " "
#FOR removing the Mongodb
#sudo service mongod stop
#sudo apt-get purge mongodb-org*
#sudo rm -r /var/log/mongodb
#sudo rm -r /var/lib/mongodb
sudo service pritunl restart
sudo service mongod start
sudo service squid3 restart
sudo service squid3 status
history -c && history -w
