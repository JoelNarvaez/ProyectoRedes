FROM ubuntu:20.04

RUN apt update && apt install -y curl iproute2 ftp iputils-ping telnet openssh-client apache2-utils

COPY reglas.sh /reglas.sh

RUN chmod +x /reglas.sh

CMD ["/bin/bash", "-c", "/reglas.sh && bash"]

#RUN apt update && apt install -y iptables curl iproute2

#RUN apt update && apt install -y iptables curl iproute2 ftp iputils-ping telnet && apt clean

