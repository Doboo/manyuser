#iptables -A OUTPUT -p tcp -m multiport --dports 25,26,465 -j REJECT --reject-with tcp-reset
#iptables -A OUTPUT -p udp -m multiport --dports 25,26,465 -j DROP

#�������
iptables -F
iptables -X
iptables -Z
#iptables -P INPUT ACCEPT
#iptables -P OUTPUT REJECT
#���ã���ֹ���������������ػ�����
iptables -P INPUT ACCEPT
iptables -P OUTPUT DROP
iptables -A INPUT -i lo -j ACCEPT
#����ping��������ɾ�˾���
iptables -A INPUT -p icmp -j ACCEPT
#����ssh
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8799 -j ACCEPT
#����ftp
iptables -A INPUT -p tcp -m tcp --dport 20 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 21 -j ACCEPT
#����tuanss�˿ڷ�Χ
iptables -A INPUT -p tcp --dport 200:3000 -j ACCEPT

#ѧϰfelix����smtp��ɱ���
iptables -A INPUT -p tcp -m tcp --dport 25 -j ACCEPT -s 127.0.0.1
iptables -A INPUT -p tcp -m tcp --dport 25 -j REJECT
#����DNS
iptables -A INPUT -p tcp -m tcp --dport 53 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
#����http��https
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
#����״̬��⣬���ý���
iptables -A INPUT -p all -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p all -m state --state INVALID,NEW -j DROP


#ֻ�������80��443
-A OUTPUT -p tcp --dport 80,443,3306 -j ACCEPT

#��������
iptables-save > /etc/iptables_tuanss
#2�����������������ļ��������ڿ�ִ��Ȩ��
touch /etc/network/if-pre-up.d/iptables_tuanss
chmod +x /etc/network/if-pre-up.d/iptables_tuanss
#3���༭�������������ļ�������Ϊ��������ʱ�ָ�iptables����
#����ϵͳ���������ļ�/etc/network/if-pre-up.d/iptables
echo "/sbin/iptables-restore < /etc/iptables.up.rules" /etc/network/if-pre-up.d/iptables_tuanss
