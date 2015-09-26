FROM shelvak/baseimage

MAINTAINER Néstor Coppi <nestorcoppi@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y install python python-pip python-dev
RUN curl -sL https://deb.nodesource.com/setup | bash -

RUN apt-get -y install nodejs
RUN adduser --shell /bin/false --gecos "" --disabled-password logio
RUN export USER=logio; export HOME=/home/logio; npm install -g log.io --user "logio"
RUN apt-get -y clean autoclean autoremove

USER logio
ENV HOME /home/logio
ENV USER logio
WORKDIR /home/logio
EXPOSE 28778 28778

RUN mkdir -p /home/logio/.log.io/
ADD harvester.conf /home/logio/.log.io/harvester.conf

ADD start.sh /start.sh

CMD sh /start.sh
