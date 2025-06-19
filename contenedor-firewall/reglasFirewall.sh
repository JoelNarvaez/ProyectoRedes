#!/bin/bash

# Permitir el trafico de paquetes
echo 1 > /proc/sys/net/ipv4/ip_forward

# Limpieza previa de reglas existentes
iptables -F
iptables -t nat -F

# Politicas por defecto
iptables -P FORWARD ACCEPT

#NAT para que cliente2 salga a internet 
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE

# 1. Denegar acceso al puerto 80 desde cliente1 (192.168.100.50)
iptables -A FORWARD -s 192.168.100.14 -p tcp --dport 80 -j REJECT --reject-with tcp-reset

# 2. Bloquear puerto 21 (FTP) para cliente con ip 192.168.100.51
iptables -A FORWARD -s 192.168.100.3 -p tcp --dport 21 -j REJECT --reject-with tcp-reset

# 3. Denegar tráfico de salida hacia el rango 192.168.100.10 - 192.168.100.100
#iptables -P FORWARD ACCEPT 
# Reglas ICMP
#iptables -I FORWARD -d 192.168.100.10/31 -p icmp -j REJECT --reject-with icmp-host-unreachable
#iptables -I FORWARD -d 192.168.100.12/30 -p icmp -j REJECT --reject-with icmp-host-unreachable
#iptables -I FORWARD -d 192.168.100.16/28 -p icmp -j REJECT --reject-with icmp-host-unreachable
#iptables -I FORWARD -d 192.168.100.32/27 -p icmp -j REJECT --reject-with icmp-host-unreachable
#iptables -I FORWARD -d 192.168.100.64/27 -p icmp -j REJECT --reject-with icmp-host-unreachable
#iptables -I FORWARD -d 192.168.100.96/30 -p icmp -j REJECT --reject-with icmp-host-unreachable
#iptables -I FORWARD -d 192.168.100.100/32 -p icmp -j REJECT --reject-with icmp-host-unreachable

iptables -I OUTPUT -d 192.168.100.10/31 -p icmp -j REJECT --reject-with icmp-host-unreachable
#iptables -I OUTPUT -d 192.168.100.12/30 -p icmp -j REJECT --reject-with icmp-host-unreachable
#iptables -I OUTPUT -d 192.168.100.16/28 -p icmp -j REJECT --reject-with icmp-host-unreachable
#iptables -I OUTPUT -d 192.168.100.32/27 -p icmp -j REJECT --reject-with icmp-host-unreachable
#iptables -I OUTPUT -d 192.168.100.64/27 -p icmp -j REJECT --reject-with icmp-host-unreachable
#iptables -I OUTPUT -d 192.168.100.96/30 -p icmp -j REJECT --reject-with icmp-host-unreachable
#iptables -I OUTPUT -d 192.168.100.100/32 -p icmp -j REJECT --reject-with icmp-host-unreachable

#iptables -I INPUT -d 192.168.100.10/31 -p icmp -j REJECT --reject-with icmp-host-unreachable
#iptables -I INPUT -d 192.168.100.12/30 -p icmp -j REJECT --reject-with icmp-host-unreachable
#iptables -I INPUT -d 192.168.100.16/28 -p icmp -j REJECT --reject-with icmp-host-unreachable
#iptables -I INPUT -d 192.168.100.32/27 -p icmp -j REJECT --reject-with icmp-host-unreachable
#iptables -I INPUT -d 192.168.100.64/27 -p icmp -j REJECT --reject-with icmp-host-unreachable
#iptables -I INPUT -d 192.168.100.96/30 -p icmp -j REJECT --reject-with icmp-host-unreachable
#iptables -I INPUT -d 192.168.100.100/32 -p icmp -j REJECT --reject-with icmp-host-unreachable


# 4. Bloquear respuestas ICMP tipo echo-reply
iptables -I FORWARD -p icmp --icmp-type echo-reply -j REJECT --reject-with icmp-host-prohibited
iptables -I OUTPUT -p icmp --icmp-type echo-reply -j REJECT --reject-with icmp-host-prohibited
iptables -I INPUT -p icmp --icmp-type echo-reply -j REJECT --reject-with icmp-host-prohibited

# 5. Bloquear puerto 25 (SMTP) para una MAC específica
iptables -A FORWARD -m mac --mac-source 02:42:ac:11:00:04 -p tcp --dport 25 -j REJECT --reject-with tcp-reset

# 6. Limitar conexiones simultáneas a 20 por IP
#iptables -A FORWARD -p tcp --syn -m connlimit --connlimit-above 20 -j REJECT

iptables -A FORWARD -p tcp --syn -m connlimit --connlimit-above 20 --connlimit-mask 32 -j REJECT

# 7. Bloquear tráfico saliente hacia HTTPS (443) desde estación de prueba (192.168.100.52)
iptables -A FORWARD -s 192.168.100.3 -p tcp --dport 443 -j REJECT --reject-with tcp-reset


# 8. Permitir solo SSH (22) desde IP autorizada (192.168.100.99)
iptables -A FORWARD -s 192.168.100.14 -p tcp --dport 22 -j ACCEPT
iptables -A FORWARD -p tcp --dport 22 -j REJECT --reject-with tcp-reset


