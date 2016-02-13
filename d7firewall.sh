
#清空配置
iptables -F

iptables -A FORWARD -p tcp --dport 25 -j DROP
iptables -A FORWARD -p tcp --dport 465 -j DROP
iptables -A INPUT -p tcp --dport 25  -j DROP
iptables -A INPUT -p tcp --dport 465  -j DROP
iptables -A OUTPUT -p tcp --dport 25 -j DROP
iptables -A OUTPUT -p tcp --dport 465 -j DROP

iptables -A OUTPUT -p tcp -m multiport --dports 25,26,109,110,143,220,366,465,587,691,993,995,2710,6881 -j REJECT --reject-with tcp-reset
iptables -A OUTPUT -p udp -m multiport --dports 25,26,109,110,143,220,366,465,587,691,993,995,2710,6881 -j DROP

printf "
####################################################
# Here is your IPs !                               #
####################################################
"
#配置转发IP
	if [ "${NETWORKIP}" == "" ];then
		/sbin/ifconfig | grep "inet addr:" | cut -d ":" -f 2 | awk '{print $1}' | grep -v "127.0.0.1"
		read -p "Input your IP for netforward:" NETWORKIP
	fi

iptables -t nat -A POSTROUTING -s 192.168.7.0/24 -j SNAT --to-source ${NETWORKIP}

#保存配置
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -A FORWARD -j REJECT
#使配置生效
touch /etc/iptables.up.rules
iptables-save > /etc/iptables.up.rules
#echo "/sbin/iptables-restore < /etc/iptables.up.rules" /etc/network/if-pre-up.d/iptables
cat > /etc/network/if-pre-up.d/iptables << EOL
#!/bin/bash
/sbin/iptables-restore < /etc/iptables.up.rules
EOL
#3、编辑该自启动配置文件，内容为启动网络时恢复iptables配置
#建立系统启动加载文件/etc/network/if-pre-up.d/iptables
chmod +x /etc/network/if-pre-up.d/iptables

