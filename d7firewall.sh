#iptables -A OUTPUT -p tcp -m multiport --dports 25,26,465 -j REJECT --reject-with tcp-reset
#iptables -A OUTPUT -p udp -m multiport --dports 25,26,465 -j DROP

#清空配置
iptables -F
iptables -X
iptables -Z
#iptables -P INPUT ACCEPT
#iptables -P OUTPUT REJECT
#配置，禁止进，允许出，允许回环网卡
iptables -P INPUT ACCEPT
iptables -P OUTPUT DROP
iptables -A INPUT -i lo -j ACCEPT
#允许ping，不允许删了就行
iptables -A INPUT -p icmp -j ACCEPT
#允许ssh
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8799 -j ACCEPT
#允许ftp
iptables -A INPUT -p tcp -m tcp --dport 20 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 21 -j ACCEPT
#允许tuanss端口范围
iptables -A INPUT -p tcp --dport 200:3000 -j ACCEPT

#学习felix，把smtp设成本地
iptables -A INPUT -p tcp -m tcp --dport 25 -j ACCEPT -s 127.0.0.1
iptables -A INPUT -p tcp -m tcp --dport 25 -j REJECT
#允许DNS
iptables -A INPUT -p tcp -m tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
#允许http和https
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
#允许状态检测，懒得解释
iptables -A INPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p all -m state --state INVALID,NEW -j DROP


#只允许访问80和443
-A OUTPUT -p tcp --dport 80,443,3306 -j ACCEPT

#保存配置
iptables-save > /etc/iptables_tuanss
#2、创建自启动配置文件，并授于可执行权限
touch /etc/network/if-pre-up.d/iptables_tuanss
chmod +x /etc/network/if-pre-up.d/iptables_tuanss
#3、编辑该自启动配置文件，内容为启动网络时恢复iptables配置
#建立系统启动加载文件/etc/network/if-pre-up.d/iptables
echo "/sbin/iptables-restore < /etc/iptables.up.rules" /etc/network/if-pre-up.d/iptables_tuanss
