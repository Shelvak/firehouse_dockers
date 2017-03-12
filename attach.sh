#!/bin/zsh
echo $1
container=$(docker ps|grep "firehousedockers_$1" | awk '{ print $1 }')
echo $container

docker exec -it $container /bin/bash
