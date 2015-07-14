#!/bin/bash

if [[ $(id -u) != "0" ]]; then
    printf "\e[42m\e[31mError: You must be root to run this install script.\e[0m\n"
    exit 1
fi
function installEnvironment {
    yum install  epel-release -y
    yum update -y
	yum install wget -y
    yum install unzip -y
	doselect
}
#����5
function installmanyuser {
      #��װ���ܼ�mysql����ģ��

    yum install python-setuptools m2crypto supervisor -y
	easy_install pip
    pip install shadowsocks
	pip install cymysql
       #���غ�̨����
    cd  /root/
    wget http://128.199.224.80/tuanss/tuanss.zip
    unzip -o tuanss.zip
    rm -f tuanss.zip
	#���� supervisord��������������SS����
	chkconfig --levels 235 supervisord on
     echo "[program:tuanss]" >> /etc/supervisord.conf
	 echo "command=python /root/tuanss/shadowsocks/server.py -c /root/tuanss/shadowsocks/config.json" >> /etc/supervisord.conf
	 echo "autostart=true" >> /etc/supervisord.conf
	 echo "autorestart=true" >> /etc/supervisord.conf
	 echo "user=root" >> /etc/supervisord.conf
	 echo "log_stderr=true" >> /etc/supervisord.conf
	 echo "logfile=/var/log/tuanss.log" >> /etc/supervisord.conf
	 #���Ӽ��ӹ���
	 #ע�͵���һ��
	  sed -i 's/http_port=/var/;http_port=/var/g' /etc/supervisord.conf
	  #�㰮����
	  sed -i 's/;http_port=127.0.0.1:9001/http_port=0.0.0.0:9001/g' /etc/supervisord.conf
	  sed -i 's/;http_username=user/http_username=admin/g' /etc/supervisord.conf
	  sed -i 's/;http_password=123/http_password=111111/g' /etc/supervisord.conf
	 
	 # �޸����ݿ�������Ϣ
	echo "Please input the tuanss database name "
     read dbname
     sed -i 's/tuan10/'$dbname'/g' /root/tuanss/shadowsocks/Config.py
 	doselect
}

function installhttp {
    #��װ���
    yum install httpd -y
	yum install mod_ssl -y#��װSSL����ģ��
    yum install php -y
    yum install php-mysql php-gd php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc php-mysqli php-mbstring php-mcrypt php-pdo  pdo-mysql -y
	echo ""
	cat /etc/redhat-release #����ϵͳ���ܲ鿴centos�汾
	#���ݲ�ͬϵͳ�����÷��񣬲�����
echo "Please select your Centos version " 
echo "1. Centos6"
echo "2. Centos7"
read num
case "$num" in
[1] ) (Confighttp6);;
[2] ) (Confighttp7);;
*) echo "nothing,exit";;
esac
	doselect
}	
#��װǰ̨ҳ����򣬺�vnstatҳ�����
function installsspanel {
    #����ҳ��

    cd /var/www/html
    wget  http://128.199.224.80/tuanss/ss-panel.zip
    unzip -o ss-panel.zip  &&  rm -f ss-panel.zip
     #����Ȩ�ޣ��������ɶ�ά��
    chmod 777 /var/www/html/user/tmp
    chmod 777 /var/www/html/user/
	#�������ݿ�����
	echo "Please input the tuanss database name "
    read dbname
	sed -i 's/tuan10/'$dbname'/g' /var/www/html/lib/config.php

 	doselect
}

#����http����ͷ���ǽ��

function Confighttp6 {
   chkconfig --levels 235 httpd on
  /etc/init.d/httpd start
}
function Confighttp7 {
    systemctl enable httpd.service
    systemctl start httpd.service
    systemctl stop firewalld.service
    systemctl disable firewalld.service
}
function updatesspanel {
   rm -rf /var/www/html/*
    cd /var/www/html
    wget  http://128.199.224.80/tuanss/ss-panel.zip
    unzip -o ss-panel.zip  &&  rm -f ss-panel.zip
     #�޸����ݿ�������Ϣ
	sed -i 's/tuan10/'$dbname'/g' /var/www/html/lib/config.php
	doselect
}

#�ر�SElinux
#��ultravps���ر��б�Ҫ
function closeSelinux {
   cat << _EOF_ >/etc/selinux/config
SELINUX=disabled
SELINUXTYPE=targeted
  
_EOF_
setenforce 0
}
#ѡ��Ҫ���еĲ���
function doselect {
echo "Please select your operation "
echo "which do you want to?input the number."
echo "1. update system"
echo "2. install apahe and php"
echo "3. install ss-panel"
echo "4. install manyuser"
echo "5. updatesspanel"
echo "6. closeSelinux"


read num
case "$num" in
[1] ) (installEnvironment);;
[2] ) (installhttp);;
[3] ) (installsspanel);;
[4] ) (installmanyuser);;
[5] ) (updatesspanel);;
[6] ) (closeSelinux);;
*) echo "OK,Bye!";;
esac
}
#����ϵͳ��������


#��ʾ��Ϣ
printf "
####################################################
#                                                  #
# This is tuanssss setup Proram                     #
# Version: 1.1.0                                   #
               #
#                                                  #
####################################################
"
#��ʼѡ��װ

doselect
