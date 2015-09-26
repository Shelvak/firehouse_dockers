#!/bin/bash

echo "Starting server"
log.io-server&
sleep 1

echo "starting harvester"

log.io-harvester
