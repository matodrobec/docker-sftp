FROM alpine:latest
MAINTAINER Adrian Dvergsdal [atmoz.net]

# Steps done in one RUN layer:
# - Install packages
# - Fix default group (1000 does not exist)
# - OpenSSH needs /var/run/sshd to run
# - Remove generic host keys, entrypoint generates unique keys
RUN echo "@community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk add --no-cache bash shadow@community openssh openssh-sftp-server fail2ban && \
    sed -i 's/GROUP=1000/GROUP=100/' /etc/default/useradd && \
    mkdir -p /var/run/sshd && \
    rm -f /etc/ssh/ssh_host_*key*

# add staff group to keep consistent with debian
RUN addgroup -g 50 staff

COPY files/sshd_config /etc/ssh/sshd_config
COPY files/create-sftp-user /usr/local/bin/
COPY files/jail.local /etc/fail2ban/
COPY files/entrypoint /

EXPOSE 22

ENTRYPOINT ["/entrypoint"]
