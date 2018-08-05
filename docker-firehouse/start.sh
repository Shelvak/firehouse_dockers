#!/bin/bash

# Mover el codigo al volumen
echo "#### Moviendo el codigo al Volumen"
rm /firehouse/public /firehouse/private /firehouse/uploads 
rm -r /firehouse/log
rm -rf /firehouse/*
ln -s /firehouse_public /firehouse/public
ln -s /firehouse_uploads /firehouse/uploads
ln -s /firehouse_private /firehouse/private
mkdir /firehouse/tmp /firehouse/log
cp -nr /usr/src/firehouse /

# Bundler y rake ya estan incluidos en la imagen
echo "#### Inicializando Rails App"
cd /firehouse && bundle install --without development && RAILS_ENV=production bundle exec rake assets:clean && bundle exec unicorn -c /firehouse/config/unicorn.rb -E production
