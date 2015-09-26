FROM phusion/baseimage

MAINTAINER Néstor Coppi <nestorcoppi@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

ADD proxy /etc/apt/apt.conf.d/01proxy

RUN apt-get update

RUN apt-get install -y build-essential software-properties-common python-software-properties \
                       git gcc g++ make adduser wget curl vim

RUN apt-get -y clean autoclean autoremove
