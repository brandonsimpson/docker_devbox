#!/usr/bin/env bash
set -e # fail on any error

NAME=${PWD##*/}

docker-machine stop $NAME