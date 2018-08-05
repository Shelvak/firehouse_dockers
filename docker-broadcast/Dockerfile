FROM ruby:2.2.10-jessie
MAINTAINER aaraujo@protonmail.ch

# Variables de entorno especificadas a modo de documentacion
ENV REDIS_HOST ""
ENV BROADCAST_IP ""
ENV GEM_HOME /home/vlc/.gem/bin
ENV PATH $GEM_HOME:$PATH
ENV firehouse_path /firehouse
ENV logs_path /logs

# Dependencias SO
# GIT esta incluido en la imagen
RUN apt-get update && \
    apt-get install -y vlc pulseaudio psmisc && \
    apt-get -y clean autoclean autoremove && \
    rm -rf /var/cache/apt/*

# Usuario para pulseaudio
RUN useradd --create-home --shell /bin/bash -p '*' vlc

# Codigo e instalacion de dependencias de Ruby
WORKDIR /usr/src/
RUN git clone -v --depth 1 https://github.com/Shelvak/firehouse_audio

ADD start.sh /start.sh

# Volumenes especificados a modo de documentacion
VOLUME ["/firehouse_audio"]
VOLUME ["/logs"]
VOLUME ["/firehouse"]
CMD ["/start.sh"]
