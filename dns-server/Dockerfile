FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y bind9 bind9utils dnsutils

COPY named.conf /etc/bind/named.conf
COPY named.conf.local /etc/bind/named.conf.local
COPY named.conf.options /etc/bind/named.conf.options
COPY db.site1.local /etc/bind/db.site1.local
COPY db.site2.local /etc/bind/db.site2.local
COPY db.site3.local /etc/bind/db.site3.local

EXPOSE 53/udp
EXPOSE 53/tcp

CMD ["named", "-g"]

