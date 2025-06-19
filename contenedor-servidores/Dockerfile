FROM ubuntu:20.04

RUN apt update && apt install -y iptables curl iproute2

COPY reglas.sh /reglas.sh

RUN chmod +x /reglas.sh

CMD ["/bin/bash", "-c", "/reglas.sh && bash"]
