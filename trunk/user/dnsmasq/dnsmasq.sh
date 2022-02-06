#!/bin/sh
storage_Path="/etc/storage"
dnsmasq_Conf="$storage_Path/dnsmasq/dnsmasq.conf"
filter_aaaa=$(nvram get dhcp_filter_aaa)
min_ttl=$(nvram get dhcp_min_ttl)

IPS4="$(ifconfig br0 | grep "inet addr" | grep -v ":127" | grep "Bcast" | awk '{print $2}' | awk -F : '{print $2}')"
IPS6="$(ifconfig br0 | grep "inet6 addr" | grep -v "fe80::" | grep -v "::1" | grep "Global" | awk '{print $3}')"
sed -i '/address=\/my.router/d' $dnsmasq_Conf
[ "$IPS4"x != x ] && cat >>$dnsmasq_Conf <<EOF
address=/my.router/$IPS4
EOF
[ "$IPS6"x != x ] && cat >>$dnsmasq_Conf <<EOF
address=/my.router/$IPS6
EOF

sed -i '/filter-AAAA/d' $dnsmasq_Conf
[ "$filter_aaaa" = 1 ] && cat >>$dnsmasq_Conf <<EOF
filter-AAAA
EOF

sed -i '/min-ttl/d' $dnsmasq_Conf
cat >>$dnsmasq_Conf <<EOF
min-ttl=$min_ttl
EOF
