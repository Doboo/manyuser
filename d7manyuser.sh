#!/bin/bash

if [[ $(id -u) != "0" ]]; then
    printf "\e[42m\e[31mError: You must be root to run this install script.\e[0m\n"
    exit 1
fi
#功能1
function highlatency {
	cat << _EOF_ >/etc/sysctl.d/local.conf
fs.file-max = 51200

net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.rmem_default = 65536
net.core.wmem_default = 65536
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 3240000

net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_congestion_control = hybla
_EOF_

#开启算法
/sbin/modprobe tcp_hybla
#优先使用
echo "net.ipv4.tcp_congestion_control=hybla" >> /etc/sysctl.conf


}
function lowlatency {
	cat << _EOF_ >/etc/sysctl.d/local.conf
fs.file-max = 51200

net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.rmem_default = 65536
net.core.wmem_default = 65536
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 3240000

net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 4096
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_congestion_control = cubic
_EOF_

}
function installEnvironment {
	#解决public key的问题
	apt-get install debian-keyring debian-archive-keyring -y
	apt-key update
	apt-get update -y
	#限制端口速度100M
	apt-get install wondershaper -y
	# limit bandwidth to 100Mb/100Mb on eth0
	wondershaper eth0 100000 100000
	#修改系统时区设置
	rm /etc/localtime
	cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	dpkg-reconfigure tzdata
	#安装系统时间同步工具
	apt-get install ntpdate
	ntpdate 129.6.15.28
	#ntpdate time.nist.org 
	#创建定时重启任务
	#crontab -e
	#设置定时器定时重启
	echo "00 05 * * * root /sbin/reboot" >>/etc/crontab
	#重启定时器
	/etc/init.d/cron restart
	#apt-get install unzip -y
	#修改系统参数限制,方法1
	echo "*                soft    nofile          65535" >>  /etc/security/limits.conf
	echo "*                hard    nofile          65535" >>  /etc/security/limits.conf
	 #方法2
	 #echo "ulimit -SHn 65535" >> /etc/rc.local
	 #方法3
	 echo "ulimit -SHn 65535" >> /etc/profile
     echo "ulimit -n 51200" >> /etc/default/supervisor
    #echo "ulimit -Sn 4096" >> /etc/default/supervisor
   # echo "ulimit -Hn 8192" >> /etc/default/supervisor
   
   #
   echo "session required pam_limits.so" >> /etc/pam.d/common-session
   
#查看支持的优化算法
sysctl net.ipv4.tcp_available_congestion_control

echo "Please select your latency"

echo "1. highlatency hybla"
echo "2. lowlatency cubic"

read num
case "$num" in
[1] ) (highlatency);;
[2] ) (lowlatency);;
*) echo "OK,Bye!";;
esac
sysctl --system
#安装ssh登录保护
apt-get install denyhosts 
#更改ssh端口
 sed -i 's/Port 22/Port 8799/g'  /etc/ssh/sshd_config
#启用ssh key登录，
  mkdir /root/.ssh
 echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAiH6uaXQA0K54of5TdpGP9v2z9CaXqnnwyNoCMwkRYPH3X7CJk61HunR59zgDoAbT/+eJiCbSEN5/27gGd1kysct/4PDzJ/JpJI3OhKk2185LRoa/BXZaGfEUz4r53M01tGTMyom9VGjFroTUHeBkj2BfAzIo+SFp+ij1RRzM75ZN/y84rGUvGR8+tM3+PbE+6W0mvY6EdKD0YY0bGtcO9xMaFB7sfZk/fUxQSNnrkfYNKA5rWIlLC3JNXwp0M77dK2pSvU3mGodC6UvWv2GU4Q++tj577M9QTv2bI6Lt7nwQHORcAZ5oknNjTKfO8cyvzN8jjCUKzj5zLave6YJB2Q== rsa-key-20150202" >> /root/.ssh/authorized_keys
	
	 sed -i 's/#AuthorizedKeysFile/AuthorizedKeysFile/g' /etc/ssh/sshd_config
	#禁用密码登录
	 sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
	
	doselect
 }
#功能5
function installmanyuser {
	echo "Please input the tuanss number "
	read  tuannum
     #安装加密及mysql访问模块
	apt-get install supervisor -y
    apt-get install -y --force-yes build-essential autoconf libtool libssl-dev curl 
	apt-get install -y python-pip git python-m2crypto  python-setuptools
    pip install cymysql
	cd /root/
	git clone https://doboo@github.com/Doboo/tuanss.git
	#用supervisord守护进程启动程序
	
	
	
	mypath="/etc/supervisor/supervisord.conf"
	 echo "[program:tuanss]" >> $mypath
	 echo "command=python /root/tuanss/server.py -c /root/tuanss/config.json" >> $mypath
	 echo "autostart=true" >> $mypath
	 echo "autorestart=true" >> $mypath
	 echo "user=root" >> $mypath
	 #是否将程序错误信息重定向的到文件
	 echo "redirect_stderr=true" >> $mypath
	 #将程序输出重定向到该文件
	 echo "stdout_logfile=/var/log/tuanss.log" >> $mypath
	 #将程序错误信息重定向到该文件
	 echo "stderr_logfile=/var/log/tuanss-err.log" >> $mypath
	  #通过网页访问日志
	 echo "[inet_http_server]" >> $mypath
	 #IP和绑定端口
	 echo "port = 0.0.0.0:9001" >> $mypath
	 #管理员名称
	 echo "username = admin" >> $mypath
	 #管理员密码
     echo "password = 111111" >> $mypath

	#修改数据库地址
	 sed -i 's/tuanDB/tuan'$tuannum'/g' /root/tuanss/Config.py
	 #将后台管理管理程序的端口随机化
	 pool=(23330 23331 23332 23333 23334 23335 23336 23337 23338 23339 23339)
	 num=${#pool[*]}
	 result=${pool[$((RANDOM%num))]}
	 echo $result
	 sed -i 's/MANAGE_PORT = 23333/MANAGE_PORT = '$result'/g' /root/tuanss/Config.py
   	 doselect
}
#功能2
function installhttp {
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
#功能3安装前台页面程序，

function installsspanel {
	echo "Please input the tuanss number "
	read  tuannum
	#删除原来的程序
	rm -rf /var/www/*
	rm -rf /var/www
	
	cd /var/
	git clone -b new https://doboo@github.com/Doboo/ss-panel.git 
	mv ss-panel www
	#修改数据库连接
	sed -i 's/tuanDB/tuan'$tuannum'/g' /var/www/lib/config.php
	#安装各种依赖，mailgun
	cd /var/www/
	curl -sS https://getcomposer.org/installer | php
	php composer.phar  install
	#配置权限，可以生成二维码
	chmod 777 /var/www/user/
	#修改网站地址域名，以重置密码等
	
	#修改导航菜单和站点名称
	sed -i 's/000000/'$tuannum'/g' /var/www/index.php
	sed -i 's/000000/'$tuannum'/g' /var/www/lib/config.php
	sed -i 's/mysitename/tuanss'$tuannum'/g' /var/www/lib/config.php
	#修改网站端口
	sed -i 's/VirtualHost *:80/VirtualHost *:8080/g' /etc/apache2/sites-enabled/000-default
	sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf
	
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
echo "1. systemSet"
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
#                                                  #
#                                                  #
####################################################
"
#开始选择安装

doselect

