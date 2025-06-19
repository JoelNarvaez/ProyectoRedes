FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y apache2 && \
    mkdir -p /var/www/site1 /var/www/site2 /var/www/site3

COPY site1 /var/www/site1
COPY site2 /var/www/site2
COPY site3 /var/www/site3

COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

EXPOSE 80

CMD ["apachectl", "-D", "FOREGROUND"]

