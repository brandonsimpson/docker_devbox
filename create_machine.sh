#!/bin/bash
#set -e # fail on any error
NAME=${PWD##*/}

# Create a new virtual machine using vmware fusion
docker-machine create --driver vmwarefusion --vmwarefusion-cpu-count 2 --vmwarefusion-disk-size 20000 --vmwarefusion-memory-size 2048 $NAME

# Upgrades a machine’s Docker client to the latest stable release.
docker-machine upgrade $NAME

