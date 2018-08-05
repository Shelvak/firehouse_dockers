FROM phusion/baseimage:0.9.18
MAINTAINER Néstor Coppi <nestorcoppi@gmail.com>

# Variables de entorno especificadas a modo de documentacion
ENV DEBIAN_FRONTEND noninteractive
ENV HOME /home/logio
ENV USER logio

# Dependencias del SO
RUN apt-get update && \
    apt-get -y install nodejs nodejs-legacy npm python python-pip python-dev && \
    apt-get -y clean autoclean autoremove && rm -rf /var/cache/apt/*

# Usuario para logio y dependencias de NodeJS
RUN adduser --shell /bin/false --gecos "" --disabled-password logio && \
    npm config set strict-ssl false && npm install -g log.io --user "logio" && \
    mkdir -p /home/logio/.log.io

# Resto del setup para Docker
USER logio
WORKDIR /home/logio
ADD harvester.conf /home/logio/.log.io/harvester.conf
ADD --chown=logio:logio start.sh /start.sh
VOLUME ["/logs"]
EXPOSE 28778
CMD ["/start.sh"]
