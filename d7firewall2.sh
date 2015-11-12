
#�������
iptables -F
iptables -X

iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
#DNS
iptables -A OUTPUT -p udp �Csport 53 -j ACCEPT
iptables -A INPUT -p udp �Cdport 53 -j ACCEPT
#��ҳ-SQL
iptables -A OUTPUT -p tcp -m multiport �Cdport 80,8080,8081,9001443,3306 -j ACCEPT
iptables -A INPUT -p tcp -m multiport �Csport 80,8080,8081,9001443,3306 -j ACCEPT
#����-SSH
iptables -A OUTPUT -p tcp -m multiport �Csport 8799,22 -j ACCEPT
iptables -A INPUT -p tcp -m multiport �Cdport 8799,22 -j ACCEPT
#�û�
iptables -A OUTPUT -p tcp �Csport914:1200 -j ACCEPT
iptables -A OUTPUT -p udp �Csport914:1200 -j ACCEPT
iptables -A INPUT -p tcp �Cdport914:1200 -j ACCEPT
iptables -A INPUT -p udp �Cdport50000:1200  -j ACCEPT
#������
iptables -A OUTPUT -p tcp �Csport914:1200  -m connlimit �Cconnlimit-above 20 -j REJECT �Creject-with tcp-reset
iptables -A INPUT -p tcp �Cdport914:1200  -m connlimit �Cconnlimit-above 20 -j REJECT �Creject-with tcp-reset
#����
iptables -A OUTPUT -p icmp -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT
#��ֹ
iptables -P OUTPUT DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP
#������SSH22�˿ڸ���
#=====================================
#���������˿�
iptables -A OUTPUT -p tcp -m multiport �Cdport 21,22,23 -j REJECT �Creject-with tcp-reset
iptables -A OUTPUT -p udp -m multiport �Cdport 21,22,23 -j DROP
#=======================================
#��������˿�
iptables -A OUTPUT -p tcp -m multiport �Cdport 24,25,50,57,105,106,109,110,143,158,209,218,220,465,587 -j REJECT �Creject-with tcp-reset
iptables -A OUTPUT -p tcp -m multiport �Cdport 993,995,1109,24554,60177,60179 -j REJECT �Creject-with tcp-reset
iptables -A OUTPUT -p udp -m multiport �Cdport 24,25,50,57,105,106,109,110,143,158,209,218,220,465,587 -j DROP
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

