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
RUN git clone -v --depth 1 https://github.com/shelvak/firehouse /firehouse

# Sobreescritura de configs
ADD start.sh /start.sh

# Resto de configuraciones para Docker
VOLUME ["/firehouse/private"]
VOLUME ["/firehouse/uploads"]
VOLUME ["/logs"]
EXPOSE 8080
CMD ["/start.sh"]
