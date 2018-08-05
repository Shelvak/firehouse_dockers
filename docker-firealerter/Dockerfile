FROM ruby:2.2.10-jessie
MAINTAINER aaraujo@protonmail.ch

# Variables de entorno especificadas a modo de documentacion
ENV REDIS_HOST ""
ENV SERVER_HOST ""
ENV logs_path ""

# Codigo e instalacion de dependencias de Ruby
WORKDIR /usr/src
RUN git clone --depth 1 -v https://github.com/Shelvak/FireAlerter.git firealerter && \
    gem install bundler && cd firealerter && bundle install

# Volumen especificado a modo de documentacion
WORKDIR /usr/src/firealerter
VOLUME ["/logs"]
EXPOSE 9800
CMD ["bundle","exec","rake"]
