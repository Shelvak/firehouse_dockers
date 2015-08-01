#!/bin/bash

echo "entrose"
echo $(ps aux |grep pulse)
pulseaudio -k
pulseaudio -D
sleep 2
echo "Pulse and icecast: "
echo $(ps aux |grep pulse)
echo $(ps aux |grep icecast)
/etc/init.d/icecast2 start
sleep 2
echo "Icecast: "
echo $(ps aux |grep icecast)

cd /firehouse_audio && bundle exec rake&
echo "Rake:"
echo $(ps aux |grep rake)


cd /

echo $(which linphonecsh)
echo $(whereis linphonecsh)
linphonecsh init
echo $(ps aux |grep linphone)
sleep 2
linphonecsh register --host 192.168.1.10 --username linphone --password linphone1234 && \
linphonecsh generic 'autoanswer enable'

darkice