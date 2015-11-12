#!/bin/bash
set -e # fail on any error

# define your local sites directory and docker machine name
VHOSTDIR=~/Sites/vhosts
NAME=${PWD##*/}

echo "Creating $NAME Docker Stack";
echo


# Switch to the new  virtual machine to use it
docker-machine env $NAME

# Run this command to configure your shell
eval "$(docker-machine env $NAME)"

echo
printf '%100s\n' | tr ' ' -
docker ps -a
printf '%100s\n' | tr ' ' -
echo

# if --rebuild flag is set then remove all existing containers
if [[ $* == *--rebuild* ]]; then

    # remove all existing containers
    echo "Removing existing containers:"
    docker rm -f $(docker ps -a -q)

    echo
    printf '%100s\n' | tr ' ' -
    echo

fi



##### MYSQL

echo "Creating MYSQL5.6.27 container:"

docker run --name mysql56 -d \
-v /mnt/hgfs$PWD/etc/mysql/conf.d:/etc/mysql/conf.d \
-v /mnt/sda1/var/lib/mysql/$NAME:/var/lib/mysql \
-p 3306:3306 \
-e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
mysql:5.6.27


echo "mysql56 logs:"
docker logs mysql56

echo
printf '%100s\n' | tr ' ' -
echo

##### REDIS

echo "Creating REDIS container:"

# Setup redis and expose port 6379:
docker run -d --name redis -p 6379:6379 redis

echo "redis logs:"
docker logs redis

echo
printf '%100s\n' | tr ' ' -
echo

##### NGINX / PHP-FPM

echo "Creating NGINX / PHP-FPM containers:"

# Start a php container with links to mysql and redis containers
# mount local virtual host work directory to where files will be run in container
docker run --name php56 -d \
-v /mnt/hgfs$VHOSTDIR:/var/www/vhosts \
-v /mnt/hgfs$PWD/etc/php/php-fpm.conf:/usr/local/etc/php-fpm.conf \
--link redis:redis --link mysql56:mysql \
katanallc/php:5.6-xdebug

# install pecl redis extension into katanall/php:5.6-xdebug container since it's missing
docker exec -it php56 bash -c 'pecl install redis && echo "extension=redis.so" > /usr/local/etc/php/conf.d/docker-php-ext-redis.ini'

docker restart php56

echo "php56 logs:"
docker logs php56

echo
printf '%100s\n' | tr ' ' -
echo

docker run --name nginx -d \
-p 80:80 \
-v /mnt/hgfs$VHOSTDIR:/var/www/vhosts \
-v /mnt/hgfs$PWD/etc/nginx/conf.d:/etc/nginx/conf.d \
--link php56:php-fpm \
nginx


#	-v /Users/brandonsimpson/Sites/vhosts:/var/www/vhosts \

echo "nginx logs:"
docker logs nginx
echo

# we have to remove redis and rebuild it after our php/nginx container is linked...
# no clue why but it doesn't allow access if this doesn't get rebuilt after the others
docker rm -f redis && docker run -d --name redis -p 6379:6379 redis


echo
printf '%100s\n' | tr ' ' -
echo


##### VARNISH

docker run --name varnish -d \
-p 8080:8080 -p 6082:6082 \
-e BACKEND_PORT=80 \
-v /mnt/hgfs$PWD/etc/varnish/default.vcl:/etc/varnish/default.vcl \
--link nginx:nginx katanallc/varnish


echo "varnish logs:"
docker logs varnish


echo
printf '%100s\n' | tr ' ' -
echo

sh stop.sh
sh start.sh


