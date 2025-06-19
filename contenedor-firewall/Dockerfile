# Imagen base Ubuntu
FROM ubuntu:20.04

# Desactiva los prompts durante instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instala iptables y herramientas de red
RUN apt-get update && \
    apt-get install -y iptables iproute2 net-tools iputils-ping curl nano && \
    apt-get clean

# Iniciar las reglas escritas en el archivo de reglasFirewall de manera automatica
COPY reglasFirewall.sh /reglasFirewall.sh
RUN chmod +x /reglasFirewall.sh   

# Inicia bash al entrar al contenedor
CMD ["/bin/bash", "-c", "/reglasFirewall.sh && bash"]


