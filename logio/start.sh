#!/bin/bash

echo "Starting server"
log.io-server&
sleep 1

echo "Starting harvester"

log.io-harvester
