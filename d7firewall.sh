
#�������
iptables -F

iptables -A FORWARD -p tcp --dport 25 -j DROP
iptables -A FORWARD -p tcp --dport 465 -j DROP
iptables -A INPUT -p tcp --dport 25  -j DROP
iptables -A INPUT -p tcp --dport 465  -j DROP
iptables -A OUTPUT -p tcp --dport 25 -j DROP
iptables -A OUTPUT -p tcp --dport 465 -j DROP

iptables -A OUTPUT -p tcp -m multiport --dports 25,26,109,110,143,220,366,465,587,691,993,995,2710,6881 -j REJECT --reject-with tcp-reset
iptables -A OUTPUT -p udp -m multiport --dports 25,26,109,110,143,220,366,465,587,691,993,995,2710,6881 -j DROP

#��������
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -A FORWARD -j REJECT
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

