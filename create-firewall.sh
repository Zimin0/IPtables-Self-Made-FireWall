#!/bin/bash

# Clear all existing rules
iptables -F # delete default rules in main table "filter" 
iptables -X # delete user's rules in main table "filter" 
iptables -t nat -F # same on nat table
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

# Default rules
iptables -P INPUT DROP # deny all incoming rules
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Allow local traffic - 127.0.0.0 and so on
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow already established connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Allowing traffic to specific ports
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow all outgoing requests
iptables -P OUTPUT ACCEPT

# Logger. Can be checked by command: grep "iptables-input-denied:" /var/log/kern.log
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables-input-denied: " --log-level 7 
iptables -A OUTPUT -m limit --limit 5/min -j LOG --log-prefix "iptables-output-denied: " --log-level 7

# Save rules
iptables-save > /etc/iptables/rules.v4
