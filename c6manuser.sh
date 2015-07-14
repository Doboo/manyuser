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
#功能5
function installmanyuser {
      #安装加密及mysql访问模块

    yum install python-setuptools m2crypto supervisor -y
	easy_install pip
    pip install shadowsocks
	pip install cymysql
       #下载后台程序
    cd  /root/
    wget http://128.199.224.80/tuanss/tuanss.zip
    unzip -o tuanss.zip
    rm -f tuanss.zip
	#设置 supervisord开机启动，启动SS进程
	chkconfig --levels 235 supervisord on
     echo "[program:tuanss]" >> /etc/supervisord.conf
	 echo "command=python /root/tuanss/shadowsocks/server.py -c /root/tuanss/shadowsocks/config.json" >> /etc/supervisord.conf
	 echo "autostart=true" >> /etc/supervisord.conf
	 echo "autorestart=true" >> /etc/supervisord.conf
	 echo "user=root" >> /etc/supervisord.conf
	 echo "log_stderr=true" >> /etc/supervisord.conf
	 echo "logfile=/var/log/tuanss.log" >> /etc/supervisord.conf
	 #增加监视功能
	 #注释掉第一行
	  sed -i 's/http_port=/var/;http_port=/var/g' /etc/supervisord.conf
	  #秀爱监听
	  sed -i 's/;http_port=127.0.0.1:9001/http_port=0.0.0.0:9001/g' /etc/supervisord.conf
	  sed -i 's/;http_username=user/http_username=admin/g' /etc/supervisord.conf
	  sed -i 's/;http_password=123/http_password=111111/g' /etc/supervisord.conf
	 
	 # 修改数据库连接信息
	echo "Please input the tuanss database name "
     read dbname
     sed -i 's/tuan10/'$dbname'/g' /root/tuanss/shadowsocks/Config.py
 	doselect
}

function installhttp {
    #安装软件
    yum install httpd -y
	yum install mod_ssl -y#安装SSL加密模块
    yum install php -y
    yum install php-mysql php-gd php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc php-mysqli php-mbstring php-mcrypt php-pdo  pdo-mysql -y
	echo ""
	cat /etc/redhat-release #调用系统功能查看centos版本
	#根据不同系统，设置服务，并启动
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
#安装前台页面程序，含vnstat页面程序
function installsspanel {
    #下载页面

    cd /var/www/html
    wget  http://128.199.224.80/tuanss/ss-panel.zip
    unzip -o ss-panel.zip  &&  rm -f ss-panel.zip
     #配置权限，可以生成二维码
    chmod 777 /var/www/html/user/tmp
    chmod 777 /var/www/html/user/
	#设置数据库连接
	echo "Please input the tuanss database name "
    read dbname
	sed -i 's/tuan10/'$dbname'/g' /var/www/html/lib/config.php

 	doselect
}

#配置http服务和防火墙等

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
     #修改数据库连接信息
	sed -i 's/tuan10/'$dbname'/g' /var/www/html/lib/config.php
	doselect
}

#关闭SElinux
#在ultravps上特别有必要
function closeSelinux {
   cat << _EOF_ >/etc/selinux/config
SELINUX=disabled
SELINUXTYPE=targeted
  
_EOF_
setenforce 0
}
#选择要进行的操作
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
#根据系统进行配置


#显示信息
printf "
####################################################
#                                                  #
# This is tuanssss setup Proram                     #
# Version: 1.1.0                                   #
               #
#                                                  #
####################################################
"
#开始选择安装

doselect
