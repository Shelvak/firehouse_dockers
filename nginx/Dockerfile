FROM shelvak/baseimage

MAINTAINER Néstor Coppi <nestorcoppi@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y nginx
RUN apt-get -y clean autoclean autoremove

RUN rm -Rf /etc/nginx/sites-available
RUN rm /etc/nginx/sites-enabled/default

ADD firehouse /etc/nginx/sites-enabled/firehouse
ADD nginx.conf /etc/nginx/nginx.conf

EXPOSE 80:80

RUN mkdir -p /logs
RUN mkdir -p /logs/nginx
RUN mkdir -p /shared

VOLUME ["/shared", "/tmp", "/logs"]

CMD nginx
