FROM ubuntu:20.04

# Evitar preguntas interactivas de tzdata, etc.
ENV DEBIAN_FRONTEND=noninteractive

# Instalar OpenSSH
RUN apt-get update && \
    apt-get install -y openssh-server postfix && \
    mkdir /var/run/sshd

# Crear usuario "user" con contraseña "123"
RUN useradd -m user && echo 'user:123' | chpasswd

# Permitir login de root y del usuario "user"
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo 'AllowUsers user root' >> /etc/ssh/sshd_config

# Exponer el puerto SSH
EXPOSE 22
EXPOSE 25

# Comando para ejecutar el servidor SSH en primer plano
CMD ["/usr/sbin/sshd", "-D"]

