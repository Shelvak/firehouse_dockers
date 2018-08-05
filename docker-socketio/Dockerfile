FROM node:6
MAINTAINER aaraujo@protonmail.ch

# Variables de entorno especificadas a modo de documentacion
ENV REDIS_HOST ""

# Codigo
WORKDIR /usr/src
RUN git clone --depth 1 https://github.com/Shelvak/firehouse_socketio

# Dependencias Node
WORKDIR /usr/src/firehouse_socketio
COPY custom/app.js /usr/src/firehouse_socketio/app.js
RUN npm install

# Resto de configuraciones para Docker
EXPOSE 8085
VOLUME ["/logs"]
CMD ["node", "app.js"]
