#!/bin/bash

pulseaudio -D
echo "Rake:"
cd /firehouse_audio
bundle exec rake
