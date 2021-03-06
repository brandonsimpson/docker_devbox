#!/usr/bin/env bash
set -e # fail on any error

ABSOLUTE_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)/`basename "${BASH_SOURCE[0]}"`
DIR=$(dirname $ABSOLUTE_PATH)
NAME=$(basename $DIR)

docker-machine start $NAME
docker-machine env $NAME
eval "$(docker-machine env $NAME)"

# Start containers in this order for service linking
docker start mysql redis php nginx varnish

echo
printf '%180s\n' | tr ' ' -
docker ps
printf '%180s\n' | tr ' ' -

echo
echo
echo "$NAME running at:"
docker-machine ip $NAME

