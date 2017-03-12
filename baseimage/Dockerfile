FROM phusion/baseimage:0.9.18

MAINTAINER Néstor Coppi <nestorcoppi@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

# Update + Nice to Have Pkg
RUN apt-get update
RUN apt-get install -y build-essential software-properties-common \
                       git gcc g++ make adduser wget curl vim ca-certificates

RUN apt-get -y clean autoclean autoremove

# Add squid ssl cert
ADD proxy.docker.dev.crt /usr/share/ca-certificates/proxy.docker.dev.crt
RUN echo 'proxy.docker.dev.crt' >> /etc/ca-certificates.conf
RUN /usr/sbin/update-ca-certificates

# Add proxy addr
ADD proxy /etc/apt/apt.conf.d/01proxy
