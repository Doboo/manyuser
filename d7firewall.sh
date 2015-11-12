
#清空配置
 iptables -F
 iptables -X
# iptables -t nat -F
# iptables -t nat -X
# iptables -t mangle -F
# iptables -t mangle -X

# SMTP Ports
iptables -A OUTPUT -p tcp -m multiport --dports 25,26,465 -j REJECT --reject-with tcp-reset
iptables -A OUTPUT -p udp -m multiport --dports 25,26,465 -j DROP
# POP Ports
iptables -A OUTPUT -p tcp -m multiport --dports 109,110,995 -j REJECT --reject-with tcp-reset
iptables -A OUTPUT -p udp -m multiport --dports 109,110,995 -j DROP

# IMAP Ports
iptables -A OUTPUT -p tcp -m multiport --dports 143,218,220,993 -j REJECT --reject-with tcp-reset
iptables -A OUTPUT -p udp -m multiport --dports 143,218,220,993 -j DROP

# Other Mail Services
iptables -A OUTPUT -p tcp -m multiport --dports 24,50,57,158,209,587,1109 -j REJECT --reject-with tcp-reset
iptables -A OUTPUT -p udp -m multiport --dports 24,50,57,158,209,587,1109 -j DROP



iptables -A OUTPUT -p tcp -m multiport –dport 24,25,50,57,105,106,109,110,143,158,209,218,220,465,587 -j REJECT –reject-with tcp-reset
iptables -A OUTPUT -p tcp -m multiport –dport 993,995,1109,24554,60177,60179 -j REJECT –reject-with tcp-reset
iptables -A OUTPUT -p udp -m multiport –dport 24,25,50,57,105,106,109,110,143,158,209,218,220,465,587 -j DROP
#保存配置
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
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

