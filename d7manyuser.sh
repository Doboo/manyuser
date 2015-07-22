#!/bin/bash

if [[ $(id -u) != "0" ]]; then
    printf "\e[42m\e[31mError: You must be root to run this install script.\e[0m\n"
    exit 1
fi
#����1
function installEnvironment {
	apt-get update -y
	#��װssh��¼����
	apt-get install denyhosts 
	#apt-get install unzip -y
	#�޸�ϵͳ��������
	echo "*                soft    nofile          8192" >>  /etc/security/limits.conf
	echo "*                hard    nofile          65535" >>  /etc/security/limits.conf
	#���ƶ˿��ٶ�100M
	apt-get install wondershaper
	# limit bandwidth to 100Mb/100Mb on eth0
	wondershaper eth0 100000 100000
	#�޸�ϵͳʱ������
	rm /etc/localtime
	cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
	dpkg-reconfigure tzdata
	#��װϵͳʱ��ͬ������
	apt-get install ntpdate
	ntpdate 129.6.15.28
	#ntpdate time.nist.org 
	#������ʱ��������
	#crontab -e
	#���ö�ʱ����ʱ����
	echo "00 05 * * * root /sbin/reboot" >>/etc/crontab
	#������ʱ��
	/etc/init.d/cron restart
	doselect
 }
#����5
function installmanyuser {
	echo "Please input the tuanss number "
	read  tuannum
     #��װ���ܼ�mysql����ģ��
	apt-get install supervisor -y
    apt-get install -y --force-yes build-essential autoconf libtool libssl-dev curl 
	apt-get install -y python-pip git python-m2crypto  python-setuptools
    pip install cymysql
	cd /root/
	git clone https://doboo@github.com/Doboo/tuanss.git
	#��supervisord�ػ�������������
	mypath="/etc/supervisor/supervisord.conf"
	 echo "[program:tuanss]" >> $mypath
	 echo "command=python /root/tuanss/server.py -c /root/tuanss/config.json" >> $mypath
	 echo "autostart=true" >> $mypath
	 echo "autorestart=true" >> $mypath
	 echo "user=root" >> $mypath
	 #�Ƿ񽫳��������Ϣ�ض���ĵ��ļ�
	 echo "redirect_stderr=true" >> $mypath
	 #����������ض��򵽸��ļ�
	 echo "stdout_logfile=/var/log/tuanss.log" >> $mypath
	 #�����������Ϣ�ض��򵽸��ļ�
	 echo "stderr_logfile=/var/log/tuanss-err.log" >> $mypath
	  #ͨ����ҳ������־
	 echo "[inet_http_server]" >> $mypath
	 #IP�Ͱ󶨶˿�
	 echo "port = 0.0.0.0:9001" >> $mypath
	 #����Ա����
	 echo "username = admin" >> $mypath
	 #����Ա����
     echo "password = 111111" >> $mypath

	#�޸����ݿ��ַ
	 sed -i 's/tuanDB/tuanss'$tuannum'/g' /root/tuanss/Config.py
	 #����̨����������Ķ˿������
	 pool=(23330 23331 23332 23333 23334 23335 23336 23337 23338 23339 23339)
	 num=${#pool[*]}
	 result=${pool[$((RANDOM%num))]}
	 echo $result
	 sed -i 's/MANAGE_PORT = 23333/MANAGE_PORT = '$result'/g' /root/tuanss/Config.py
   	 doselect
}
#����2
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
#����3��װǰ̨ҳ�����

function installsspanel {
	echo "Please input the tuanss number "
	read  tuannum
	#ɾ��ԭ���ĳ���
	rm -rf /var/www/*
	rm -rf /var/www
	
	cd /var/
	git clone -b new https://doboo@github.com/Doboo/ss-panel.git 
	mv ss-panel www
	#�޸����ݿ�����
	sed -i 's/tuanDB/tuanss'$tuannum'/g' /var/www/lib/config.php
	#��װ����������mailgun
	cd /var/www/
	curl -sS https://getcomposer.org/installer | php
	php composer.phar  install
	#����Ȩ�ޣ��������ɶ�ά��
	chmod 777 /var/www/user/
	#�޸���վ��ַ�����������������
	
	#�޸ĵ����˵���վ������
	sed -i 's/000000/'$tuannum'/g' /var/www/index.php
	sed -i 's/000000/'$tuannum'/g' /var/www/lib/config.php
	sed -i 's/mysitename/tuanss'$tuannum'/g' /var/www/lib/config.php
	doselect
}

#����5 ��װmysql���ݿ��php myadmin
function installmysql {
   apt-get install mysql-server mysql-client -y
   apt-get install phpmyadmin -y
}
#����6 ��װserverspeeder
function installserverspeeder {
	wget http://my.serverspeeder.com/d/ls/serverSpeederInstaller.tar.gz
	tar xzvf serverSpeederInstaller.tar.gz 
	bash serverSpeederInstaller.sh
	sed -i 's/advinacc="0"/advinacc="1"/g' /serverspeeder/etc/config
	sed -i 's/maxmode="0"/maxmode="1"/g' /serverspeeder/etc/config
	sed -i 's/rsc=""/rsc="1"/g' /serverspeeder/etc/config
  }

#����ҳ�����


#ѡ��Ҫ���еĲ���
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
#����ϵͳ��������
#��ʾ��Ϣ
printf "
####################################################
#                                                  #
# This is manyuser setup Proram  for debian7        #
#                 #
#                                                  #
####################################################
"
#��ʼѡ��װ

doselect

