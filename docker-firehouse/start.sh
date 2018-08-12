#!/bin/bash

mkdir /firehouse/tmp

# Bundler y rake ya estan incluidos en la imagen
echo "#### Inicializando Rails App"
cd /firehouse 
bundle install --without development test --deployment --jobs=4 
bundle exec rake assets:precompile 
bundle exec rake db:migrate
bundle exec unicorn -c /firehouse/config/unicorn.rb -E production
