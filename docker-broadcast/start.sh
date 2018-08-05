#!/bin/bash

# Mover el codigo al volumen
# /firehouse_audio es creado por el montaje en docker-compose
echo "#### Moviendo el codigo al Volumen"
rm -rf /firehouse_audio/*
cp -r /usr/src/firehouse_audio/* /firehouse_audio/
chown -R vlc:vlc /firehouse_audio
chown -R vlc:vlc /logs

# Inicializacion de aplicacion
echo "#### Iniciando Pulseaudio"
pulseaudio -D --system

# Bundler y rake ya estan incluidos en la imagen
echo "#### Inicializando Rails App"
runuser -l vlc -s /bin/bash -c "export REDIS_HOST=$REDIS_HOST && \
                                export BROADCAST_IP=$BROADCAST_IP && \
                                export GEM_HOME=$GEM_HOME && \
                                export PATH=$GEM_HOME/ruby/2.2.0/bin:$PATH && \
                                export firehouse_path=$firehouse_path && \
                                export logs_path=$logs_path && \
                                cd /firehouse_audio && bundle install --path $GEM_PATH && bundle exec rake"
