FROM shelvak/baseimage

MAINTAINER Néstor Coppi <nestorcoppi@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y npm nodejs-legacy
RUN apt-get -y clean autoclean autoremove

RUN git clone https://github.com/FRM-UTN/firehouse_socketio

WORKDIR /firehouse_socketio
RUN npm install

EXPOSE 8085:8085

CMD nodejs app.js
