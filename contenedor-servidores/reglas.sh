#!/bin/bash

# Esperar al firewall
sleep 5

# Definir la ip de firewall como el gateway de cliente
ip route replace default via 192.168.100.140

