
#清空配置
iptables -F
iptables -X

iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
#DNS
iptables -A OUTPUT -p udp –sport 53 -j ACCEPT
iptables -A INPUT -p udp –dport 53 -j ACCEPT
#网页-SQL
iptables -A OUTPUT -p tcp -m multiport –dport 80,8080,8081,9001443,3306 -j ACCEPT
iptables -A INPUT -p tcp -m multiport –sport 80,8080,8081,9001443,3306 -j ACCEPT
#代理-SSH
iptables -A OUTPUT -p tcp -m multiport –sport 8799,22 -j ACCEPT
iptables -A INPUT -p tcp -m multiport –dport 8799,22 -j ACCEPT
#用户
iptables -A OUTPUT -p tcp –sport914:1200 -j ACCEPT
iptables -A OUTPUT -p udp –sport914:1200 -j ACCEPT
iptables -A INPUT -p tcp –dport914:1200 -j ACCEPT
iptables -A INPUT -p udp –dport50000:1200  -j ACCEPT
#连接数
iptables -A OUTPUT -p tcp –sport914:1200  -m connlimit –connlimit-above 20 -j REJECT –reject-with tcp-reset
iptables -A INPUT -p tcp –dport914:1200  -m connlimit –connlimit-above 20 -j REJECT –reject-with tcp-reset
#其他
iptables -A OUTPUT -p icmp -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
#禁止
iptables -P OUTPUT DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP
#请把你的SSH22端口改了
#=====================================
#屏蔽其他端口
iptables -A OUTPUT -p tcp -m multiport –dport 21,22,23 -j REJECT –reject-with tcp-reset
iptables -A OUTPUT -p udp -m multiport –dport 21,22,23 -j DROP
#=======================================
#屏蔽邮箱端口
iptables -A OUTPUT -p tcp -m multiport –dport 24,25,50,57,105,106,109,110,143,158,209,218,220,465,587 -j REJECT –reject-with tcp-reset
iptables -A OUTPUT -p tcp -m multiport –dport 993,995,1109,24554,60177,60179 -j REJECT –reject-with tcp-reset
iptables -A OUTPUT -p udp -m multiport –dport 24,25,50,57,105,106,109,110,143,158,209,218,220,465,587 -j DROP
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

