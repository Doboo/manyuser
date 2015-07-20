#!/bin/bash

if [[ $(id -u) != "0" ]]; then
    printf "\e[42m\e[31mError: You must be root to run this install script.\e[0m\n"
    exit 1
fi
function installEnvironment {
    apt-get update -y
	#安装ssh登录保护
	apt-get install denyhosts 
    #apt-get install unzip -y
	#修改系统参数限制
	echo "*                soft    nofile          8192" >>  /etc/security/limits.conf
	echo "*                hard    nofile          65535" >>  /etc/security/limits.conf
		#限制端口速度100M
	apt-get install wondershaper
# limit bandwidth to 100Mb/100Mb on eth0
   wondershaper eth0 100000 100000
   
   #修改系统时区设置
   rm /etc/localtime
   cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
   dpkg-reconfigure tzdata
   #安装系统时间同步工具
   apt-get install ntpdate
   ntpdate 129.6.15.28
   ntpdate time.nist.org 
   #创建定时重启任务
   crontab -e
   
  #查看定时器设置
  crontab -l
   doselect
   
}
#功能5
function installmanyuser {
     #安装加密及mysql访问模块
	apt-get install supervisor -y
    apt-get install -y --force-yes build-essential autoconf libtool libssl-dev curl 
	apt-get install -y python-pip git python-m2crypto  python-setuptools
    pip install cymysql
    
    #下载后台程序
    cd  /root/
    #wget  http://128.199.224.80/tuanss/tuanss.zip
    #unzip -o tuanss.zip
    #rm -f tuanss.zip
	git clone https://doboo@github.com/Doboo/tuanss.git
	#用supervisord守护进程启动程序
	
	 echo "[program:tuanss]" >> /etc/supervisor/supervisord.conf
	 echo "command=python /root/tuanss/server.py -c /root/tuanss/config.json" >> /etc/supervisor/supervisord.conf
	 echo "autostart=true" >> /etc/supervisor/supervisord.conf
	 echo "autorestart=true" >> /etc/supervisor/supervisord.conf
	 echo "user=root" >> /etc/supervisor/supervisord.conf
	 #是否将程序错误信息重定向的到文件
	 echo "redirect_stderr=true" >> /etc/supervisor/supervisord.conf
	 #将程序输出重定向到该文件
	 echo "stdout_logfile=/var/log/tuanss.log" >> /etc/supervisor/supervisord.conf
	 #将程序错误信息重定向到该文件
	 echo "stderr_logfile=/var/log/tuanss-err.log" >> /etc/supervisor/supervisord.conf
	  #通过网页访问日志
	 echo "[inet_http_server]" >> /etc/supervisor/supervisord.conf
	 #IP和绑定端口
	 echo "port = 0.0.0.0:9001" >> /etc/supervisor/supervisord.conf
	 #管理员名称
	 echo "username = admin" >> /etc/supervisor/supervisord.conf
	 #管理员密码
     echo "password = 111111" >> /etc/supervisor/supervisord.conf

	#修改数据库地址
	 sed -i 's/tuanDB/'$dbname'/g' /root/tuanss/Config.py
	 #将后台管理管理程序的端口随机化
	 pool=(23330 23331 23332 23333 23334 23335 23336 23337 23338 23339 23339)
	 num=${#pool[*]}
	 result=${pool[$((RANDOM%num))]}
	 echo $result
	 sed -i 's/MANAGE_PORT = 23333/MANAGE_PORT = '$result'/g' /root/tuanss/Config.py


num=${#pool[*]}

result=${pool[$((RANDOM%num))]}
   	doselect
}
function installhttp {
    #安装软件
    apt-get install apache2 -y
	#Installing PHP5
	apt-get install php5 libapache2-mod-php5 -y
	/etc/init.d/apache2 restart
	#Getting MySQL Support In PHP5
	apt-cache search php5
	apt-get install php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl -y
	   /etc/init.d/apache2 restart
	 apt-get install php-apc -y
	 /etc/init.d/apache2 restart
	doselect
}	
#安装前台页面程序，含vnstat页面程序
function installsspanel {
    #安装软件
    #下载页面
    cd /var/
   # wget   http://128.199.224.80/tuanss/ss-panel.zip
   # unzip -o ss-panel.zip  &&  rm -f ss-panel.zip
	#rm -f /var/www/index.html
	rm -rf /var/www/*
	rm -rf /var/www
	#新的版本分支
	git clone -b new https://doboo@github.com/Doboo/ss-panel.git 
	#修改数据库连接
	mv ss-panel www
	sed -i 's/tuanDB/'$dbname'/g' /var/www/lib/config.php
	#安装各种依赖，mailgun
	cd /var/www/
	curl -sS https://getcomposer.org/installer | php
	php composer.phar  install
     #配置权限，可以生成二维码
    chmod 777 /var/www/user/tmp
    chmod 777 /var/www/user/
	#修改网站地址域名，以重置密码等
	echo "Please input the tuanss number "
    read  tuannum
	#修改导航菜单和站点名称
	sed -i 's/000000/'$tuannum'/g' /var/www/index.php
	sed -i 's/000000/'$tuannum'/g' /var/www/lib/config.php
	sed -i 's/mysitename/tuanss'$tuannum'/g' /var/www/lib/config.php
	doselect
}

#功能5 安装mysql数据库和php myadmin
function installmysql {
   apt-get install mysql-server mysql-client -y
   apt-get install phpmyadmin -y
}
#功能6 安装serverspeeder
function installserverspeeder {
   wget http://my.serverspeeder.com/d/ls/serverSpeederInstaller.tar.gz
   tar xzvf serverSpeederInstaller.tar.gz 
   bash serverSpeederInstaller.sh
   sed -i 's/advinacc="0"/advinacc="1"/g' /serverspeeder/etc/config
   sed -i 's/maxmode="0"/maxmode="1"/g' /serverspeeder/etc/config
   sed -i 's/rsc=""/rsc="1"/g' /serverspeeder/etc/config
  }

#更新页面程序


#选择要进行的操作
function doselect {
echo "Please select your operation "
echo "which do you want to?input the number."
echo "1. update system"
echo "2. install apahe and php"
echo "3. install ss-panel"
echo "4. install manyuser"
echo "5. install mysql and phpmyadmin"
echo "6. install serverspeeder"
echo "7. update ss-panel"

read num
case "$num" in
[1] ) (installEnvironment);;
[2] ) (installhttp);;
[3] ) (installsspanel);;
[4] ) (installmanyuser);;
[5] ) (installmysql);;
[6] ) (installserverspeeder);;
*) echo "OK,Bye!";;
esac
}
#根据系统进行配置
#显示信息
printf "
####################################################
#                                                  #
# This is manyuser setup Proram  for debian7        #
#                 #
#                                                  #
####################################################
"
#开始选择安装
echo "Please input the tuanss database name "
read dbname
doselect

