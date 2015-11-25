#!/usr/bin/env bash
set -e # fail on any error

ABSOLUTE_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)/`basename "${BASH_SOURCE[0]}"`
DIR=$(dirname $ABSOLUTE_PATH)
NAME=$(basename $DIR)

docker-machine stop $NAME