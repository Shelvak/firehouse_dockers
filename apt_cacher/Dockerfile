FROM shelvak/baseimage

MAINTAINER Néstor Coppi <nestorcoppi@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# We don't need that file here =P
RUN rm /etc/apt/apt.conf.d/01proxy

RUN apt-get update && apt-get install -y apt-cacher-ng

RUN apt-get -y clean autoclean autoremove

VOLUME ["/var/cache/apt-cacher-ng"]
EXPOSE 3142:3142

CMD chmod 777 /var/cache/apt-cacher-ng && /etc/init.d/apt-cacher-ng start && tail -f /var/log/apt-cacher-ng/*
