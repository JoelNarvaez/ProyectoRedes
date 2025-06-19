FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y squid && \
    rm -f /etc/squid/squid.conf

COPY squid.conf /etc/squid/
COPY blacklist.txt /etc/squid/
COPY blocked_sites.acl /etc/squid/

CMD ["squid", "-N", "-d", "1"]

