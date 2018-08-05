FROM ruby:2.2.10-jessie
MAINTAINER aaraujo@protonmail.ch

# Variables de entorno para acceso a base de datos
# ENV DB_DEV_HOST ""
# ENV DB_DEV_NAME ""
# ENV DB_DEV_USR ""
# ENV DB_DEV_PWD ""
# ENV DB_TEST_HOST ""
# ENV DB_TEST_NAME ""
# ENV DB_TEST_USR ""
# ENV DB_TEST_PWD ""
# ENV DB_PROD_HOST ""
# ENV DB_PROD_NAME ""
# ENV DB_PROD_USR ""
# ENV DB_PROD_PWD ""

# Variables de entorno restantes
# ENV SERVER_HOST ""
# ENV REDIS_HOST ""
# ENV SOCKETIO_HOST ""
# ENV RAILS_ENV ""

# Dependencias SO
RUN apt-get update && \
    apt-get install -y nodejs postgresql-server-dev-9.4 imagemagick && \
    apt-get -y clean autoclean autoremove && rm -rf /var/cache/apt/*

# Codigo
# WORKDIR /usr/src
RUN echo "0.3" && git clone -v --depth 1 https://github.com/shelvak/firehouse /usr/src/firehouse
WORKDIR /usr/src/firehouse

# Sobreescritura de configs
ADD config/app_config.yml /usr/src/firehouse/config/app_config.yml
ADD config/database.yml /usr/src/firehouse/config/database.yml
ADD config/unicorn.rb /usr/src/firehouse/config/unicorn.rb
ADD config/secrets.yml /usr/src/firehouse/config/secrets.yml
ADD start.sh /start.sh

# Sobreescritura de customizaciones
# ADD custom/interventions_updater.js.erb /usr/src/firehouse/app/assets/javascripts/maps/interventions_updater.js.erb
ADD custom/production.rb /usr/src/firehouse/config/environments/production.rb

# Resto de configuraciones para Docker
VOLUME ["/firehouse"]
VOLUME ["/firehouse_public"]
VOLUME ["/firehouse_private"]
VOLUME ["/firehouse_uploads"]
VOLUME ["/logs"]
EXPOSE 8080
CMD ["/start.sh"]
