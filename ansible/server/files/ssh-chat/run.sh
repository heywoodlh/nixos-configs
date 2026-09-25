#!/usr/bin/env ash

[ -e /data/ssh/id_rsa ] || ssh-keygen -t rsa -C "chatkey" -f /data/ssh/id_rsa
/usr/local/bin/ssh-chat --bind "0.0.0.0:22" --identity=/data/ssh/id_rsa --admin=/opt/admin_authorized_keys --motd=/opt/motd.txt --whitelist=/opt/authorized_keys
