#!/bin/bash
vpnproxy_wan_port=9999
vpnproxy_vpn_port=1194

vpnproxy_close () {

iptables -t filter -D INPUT -p tcp --dport $vpnproxy_wan_port -j ACCEPT
killall nvpproxy
killall -9 nvpproxy
}

vpnproxy_start () {

logger -t "【vpnproxy】" "运行 /usr/bin/nvpproxy"
eval "/usr/bin/nvpproxy -port=$vpnproxy_wan_port -proxy=127.0.0.1:$vpnproxy_vpn_port " &
vpnproxy_port_dpt
}


vpnproxy_port_dpt () {

port=$(iptables -t filter -L INPUT -v -n --line-numbers | grep dpt:$vpnproxy_wan_port | cut -d " " -f 1 | sort -nr | wc -l)
if [ "$port" = 0 ] ; then
	logger -t "【vpnproxy】" "允许 $vpnproxy_wan_port 端口通过防火墙"
	iptables -t filter -I INPUT -p tcp --dport $vpnproxy_wan_port -j ACCEPT
fi

}

case $1 in
start)
	vpnproxy_start
	;;
stop)
	vpnproxy_close
	;;
esac
