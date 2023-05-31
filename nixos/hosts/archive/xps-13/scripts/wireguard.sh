#!/run/current-system/sw/bin/bash

internal_wifi_regex="HeywoodNTWK"
wifi_interface="wlp0s20f3"
external_wireguard_interface="shadow-external"
internal_wireguard_interface="shadow-internal"

PATH="/etc/profiles/per-user/heywoodlh/bin:/run/current-system/sw/bin:/home/heywoodlh/bin:/home/heywoodlh/go/bin:/home/heywoodlh/.local/bin:/home/heywoodlh/bin:/home/heywoodlh/go/bin:/usr/bin/:/usr/sbin:/bin:/sbin:/usr/local/bin"

wg-quick up mullvad

while read line
do
	if echo ${line} | grep -qE ${internal_wifi_regex}
	then
		echo "On home wifi"

		if ps aux | grep -i 'openconnect' | grep -q 'pa-vpn.mychg.com'
		then
			echo 'On home wifi, but on CHG VPN'
			ip addr | grep -qE ${internal_wireguard_interface} && echo "Bringing down ${internal_wireguard_interface}" && wg-quick down ${internal_wireguard_interface}
			ip addr | grep -qE ${external_wireguard_interface} && echo "Bringing down ${external_wireguard_interface}" && wg-quick down ${external_wireguard_interface}
		else
			ip addr | grep -qE ${external_wireguard_interface} && echo "Bringing down ${external_wireguard_interface}" && wg-quick down ${external_wireguard_interface}
			ip addr | grep -qE ${internal_wireguard_interface} || echo "Bringing up ${internal_wireguard_interface}" && wg-quick up ${internal_wireguard_interface}
		fi
	else
		echo "Not on home wifi"
		ip addr | grep -qE ${internal_wireguard_interface} && echo "Bringing down ${internal_wireguard_interface}" && wg-quick down ${internal_wireguard_interface}
		ip addr | grep -qE ${external_wireguard_interface} || echo "Bringing up ${external_wireguard_interface}" && wg-quick up ${external_wireguard_interface}
	fi
done < <(while true; do nmcli c | grep ${wifi_interface} ; sleep 2; done)
