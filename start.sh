#!/usr/bin/env bash
set -e # fail on any error

NAME=${PWD##*/}

docker-machine start $NAME
docker-machine env $NAME
eval "$(docker-machine env $NAME)"

# Start containers in this order for service linking
docker start mysql56 redis php56 nginx varnish

echo
printf '%180s\n' | tr ' ' -
docker ps
printf '%180s\n' | tr ' ' -

echo
echo
echo "$NAME running at:"
docker-machine ip $NAME

