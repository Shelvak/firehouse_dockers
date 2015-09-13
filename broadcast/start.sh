#!/bin/bash

pulseaudio -D --system
echo "Rake:"
cd /firehouse_audio
bundle exec rake

