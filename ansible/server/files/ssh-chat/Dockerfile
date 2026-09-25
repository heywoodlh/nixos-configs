FROM docker.io/heywoodlh/ssh-chat:latest

COPY admin_authorized_keys /opt/admin_authorized_keys
COPY authorized_keys /opt/authorized_keys
COPY motd.txt /opt/motd.txt
COPY run.sh /run.sh

RUN mkdir -p /root/ssh

VOLUME /root/ssh

EXPOSE 22

ENTRYPOINT ["ash", "/run.sh"]
