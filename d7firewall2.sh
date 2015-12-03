
#清空配置
iptables -F
#默认策略

#允许出的
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 3306 -j ACCEPT
iptables -A OUTPUT -p udp --dport 3306 -j ACCEPT
# limit
iptables -A OUTPUT -m limit --limit 30/s -j ACCEPT

#防止发送垃圾端口
iptables -A FORWARD -p tcp --dport 25 -j DROP
iptables -A FORWARD -p tcp --dport 465 -j DROP
iptables -A INPUT -p tcp --dport 25  -j DROP
iptables -A INPUT -p tcp --dport 465  -j DROP
iptables -A OUTPUT -p tcp --dport 25 -j DROP
iptables -A OUTPUT -p tcp --dport 465 -j DROP


# iptables -A INPUT -i lo -j ACCEPT
# iptables -A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT
# iptables -A INPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT
# iptables -A INPUT -p tcp -m state --state NEW --dport XXX -j ACCEPT
# iptables -A INPUT -p tcp --dport 80 -j ACCEPT
# iptables -A INPUT -p tcp --dport 80 -m limit --limit 100/minute --limit-burst 100 -j ACCEPT
# iptables -A INPUT -p tcp --dport 443 -j ACCEPT
# iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
# iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
# iptables -A INPUT DROP
# iptables -P INPUT DROP

iptables -P INPUT ACCEPT
iptables -A OUTPUT -j DROP
iptables -P OUTPUT DROP
iptables -A FORWARD -j REJECT
iptables -P FORWARD DROP

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

