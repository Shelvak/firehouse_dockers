FROM phusion/baseimage:latest

MAINTAINER Néstor Coppi <nestorcoppi@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# Add squid ssl cert
RUN apt-get install curl ca-certificates
ADD proxy /etc/apt/apt.conf.d/01proxy
ADD proxy.docker.dev.crt /usr/share/ca-certificates/proxy.docker.dev.crt
RUN echo 'proxy.docker.dev.crt' >> /etc/ca-certificates.conf
RUN /usr/sbin/update-ca-certificates

# Update + Nice to Have Pkg
RUN apt-get update
RUN apt-get install -y build-essential software-properties-common \
                       git gcc g++ make adduser wget curl vim ca-certificates

RUN apt-get -y clean autoclean autoremove

