#!/run/current-system/sw/bin/bash

external_wireguard_interface="shadow-external"
internal_wireguard_interface="shadow-internal"
wifi_interface="wlp2s0"
internal_wifi_regex="HeywoodNTWK"
home_subnet_pattern='192.168.50.'

PATH="/etc/profiles/per-user/heywoodlh/bin:/run/current-system/sw/bin:/home/heywoodlh/bin:/home/heywoodlh/go/bin:/home/heywoodlh/.local/bin:/home/heywoodlh/bin:/home/heywoodlh/go/bin:/usr/bin/:/usr/sbin:/bin:/sbin:/usr/local/bin"

while read line
do
	echo 'Detected wired connection'

        if nmcli c show --active | grep "${wifi_interface}" | grep -qE ${internal_wifi_regex}
        then
                echo "On home wifi, doing nothing"
	else
		if ip addr | grep "${home_subnet_pattern}"
		then
			echo 'Likely on home network, doing nothing'
		else
			echo 'Not on home network, connecting to external Wireguard'
			ip addr | grep -qE ${internal_wireguard_interface} && echo "Bringing down ${internal_wireguard_interface}" && wg-quick down ${internal_wireguard_interface}
			ip addr | grep -qE ${external_wireguard_interface} || echo "Bringing up ${external_wireguard_interface}" && wg-quick up ${external_wireguard_interface}
		fi
	fi
done < <(while true; do nmcli c show --active | grep -i 'wired' | grep 'ethernet'; sleep 2; done)
