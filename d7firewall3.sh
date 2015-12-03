
#清空配置
iptables -F
#默认策略

#允许出的
iptables -t filter -A OUTPUT -d 127.0.0.1 -j ACCEPT
iptables -t filter -m owner --uid-owner root -A OUTPUT -p tcp --sport 1080 -j ACCEPT
iptables -t filter -m owner --uid-owner root -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -t filter -m owner --uid-owner root -A OUTPUT -p tcp --dport 443 -j ACCEPT
iptables -t filter -m owner --uid-owner root -A OUTPUT -p tcp --dport 3306 -j ACCEPT
iptables -t filter -m owner --uid-owner root -A OUTPUT -p tcp -j REJECT --reject-with tcp-reset

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

