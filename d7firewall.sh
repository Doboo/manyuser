
#�������
 iptables -F
 iptables -X
# iptables -t nat -F
# iptables -t nat -X
# iptables -t mangle -F
# iptables -t mangle -X

# SMTP Ports
#iptables -A OUTPUT -p tcp -m multiport --dports 25,26,465 -j REJECT --reject-with tcp-reset
iptables -A OUTPUT -p tcp -m multiport --dports 25,26,465 -j DROP
iptables -A OUTPUT -p udp -m multiport --dports 25,26,465 -j DROP
# POP Ports
#iptables -A OUTPUT -p tcp -m multiport --dports 109,110,995 -j REJECT --reject-with tcp-reset
iptables -A OUTPUT -p tcp -m multiport --dports 109,110,995 -j DROP
iptables -A OUTPUT -p udp -m multiport --dports 109,110,995 -j DROP

# IMAP Ports
#iptables -A OUTPUT -p tcp -m multiport --dports 143,218,220,993 -j REJECT --reject-with tcp-reset
iptables -A OUTPUT -p tcp -m multiport --dports 143,218,220,993 -j DROP
iptables -A OUTPUT -p udp -m multiport --dports 143,218,220,993 -j DROP

# Other Mail Services
iptables -A OUTPUT -p tcp -m multiport --dports 24,50,57,158,209,587,1109 -j REJECT --reject-with tcp-reset
iptables -A OUTPUT -p udp -m multiport --dports 24,50,57,158,209,587,1109 -j DROP


#��������
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
#ʹ������Ч
touch /etc/iptables.up.rules
iptables-save > /etc/iptables.up.rules
#echo "/sbin/iptables-restore < /etc/iptables.up.rules" /etc/network/if-pre-up.d/iptables
cat > /etc/network/if-pre-up.d/iptables << EOL
#!/bin/bash
/sbin/iptables-restore < /etc/iptables.up.rules
EOL
#3���༭�������������ļ�������Ϊ��������ʱ�ָ�iptables����
#����ϵͳ���������ļ�/etc/network/if-pre-up.d/iptables
chmod +x /etc/network/if-pre-up.d/iptables

