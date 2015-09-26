FROM phusion/baseimage

MAINTAINER Néstor Coppi <nestorcoppi@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

RUN apt-get -y install curl && curl -sL https://deb.nodesource.com/setup | bash -

RUN apt-get -y install adduser make gcc g++ nodejs
RUN adduser --shell /bin/false --gecos "" --disabled-password logio
RUN export USER=logio; export HOME=/home/logio; npm install -g log.io --user "logio"

USER logio
ENV HOME /home/logio
ENV USER logio
WORKDIR /home/logio
EXPOSE 28778 28778

CMD log.io-harvester
