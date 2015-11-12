# Katana Dev Team Docker Environment

This package allows you to create a new docker machine, install our current development stack, 
link all required services together, and easily drop in new virtual host configurations for new sites.

**Goal**

The goal is to have all of us running on the same development stack. If one of us needs a new version of software, 
we should all be able to install it via code by simply doing a `git pull` and `sh build.sh --rebuild` command to have
the latest software required to continue development.

**Requirements:**

* OS X
* VMware Fusion
* Docker Machine - https://www.docker.com/docker-toolbox

**Bugs**

This is a work in progress. There have been many many many bugs along the way. If you run into any issues, please attempt to 
fix them via code or a reproducible manner so we can all keep our development environments up-to-date.

---

## Installation

1. Make sure your work directory is accessible via /Users/*yourname*/Sites/vhosts. If you don't currently have this
setup, you can create a symbolic link to your existing work directory. The nginx/php containers will be mounting your 
local /Users/*yourname*/Sites/vhosts folder to /var/www/vhosts.

2. `mysqldump --all-databases` from your current mysql server(s) to import later.

3. Create a new folder which you want to call your new docker machine. For example, to create a new machine called `katana` we'll create a new folder:
    
    ```
    mkdir -p ~/Sites/docker/katana
    ```

4. Change into your new directory: `cd ~/Sites/docker/katana`

5. Clone this repo into your new directory:

    ```
    git clone git@github.com:KatanaLLC/dev-docker.git .
    ``` 
    
6. Create a new docker machine:

    ```
    sh create_machine.sh
    ```
    
7. Build your container stack in your new machine:

    ```
    sh build.sh
    ```
    
8. Update your `/etc/hosts` entries for the local hostnames below to point to the ip address output after your new machine restarts.

9. Mysql import your db dump files into your new mysql server.

10. Profit


---


## Create Docker Machine

Create a docker machine using the vmwarefusion driver. A new machine name will be based on the current folder name being run in, i.e. katana

Defaults:

* CPUs: 2
* Disk Size: 30GB
* Memory: 2048MB

```
sh create_machine.sh
```

---


## Build Docker Containers

Create all containers in the order they need to work

    sh build.sh
    
If you would like to rebuild all containers add the `--rebuild` flag. 
*THIS WILL REMOVE ALL CONTAINERS AND ANY NON-PERSISTENT DATA*

    sh build.sh --rebuild

    
---


## Use It

**Start / Stop docker machine**

This will start the docker machine and all containers in order that they need to start for links to work

    sh start.sh
    
    sh stop.sh

**Get ip address of machine:**

    docker-machine ip <machine>
    
**Switch into docker machine environment:**

    docker-machine env <machine>
    eval "$(docker-machine env <machine>)"
    
**SSH into docker machine:**

    docker-machine ssh <machine>
    
**Enter bash prompt inside of a container:**

    docker exec -it <container> bash

**Watch logs of a container:**

    docker logs -f <container>

    
---


## Nginx VirtualHost Configuration

1. All conf files in `etc/nginx/conf.d` are loaded into the nginx container on restart. New conf files can be dropped 
in place and the nginx container restarted for a new virtual host to load.

2. The nginx container is configured to mount your local `/Users/*username*/Sites/vhosts` directory to `/var/www/vhosts`
 within the container. All of your site directories should be inside of your local vhost folder for easy discovery. 
 If you wish to change this, change the `VHOSTDIR` setting in build.sh and re-build your containers.
 
3. Custom environment variables can be set with additional fastcgi_param parameters, for example:

    ```
    fastcgi_param MAGE_RUN_CODE hhu;
    fastcgi_param MAGE_RUN_TYPE store;
    ```    
    
**Hostnames Configured:**

* **hhu.dev** (hay house university laravel site)
* **local.hayhouse.com** (hay house magento - hhus)
* **local.hayhouse.co.uk** (hay house magento - hhuk)
* **local.hayhouse.com.au** (hay house magento - hhau)
* **local.hayhouseradio.com** (hay house radio)
* **local.hayhouseuniversity.com** (hay house magento - hhu)
* **local.suzeorman.com** (hay house magento - suzeorman)

    
---

## MySQL Configuration

The database allows connections as root without password.

* Hostname: mysql
* User: root
* *no password*
* Port: 3306

Example .env settings:

    DB_CONNECTION=mysql
    DB_HOST=mysql
    DB_DATABASE=yourdbname
    DB_USERNAME=root
    DB_PASSWORD=
    
Any custom mysql cnf files in `etc/mysql/conf.d` will be loaded when the container is restarted.

---

## Redis Configuration


* Hostname: redis
* Port: 6379

---

## Varnish Configuration 

* Hostname: varnish
* Port: 8080
* Port 6082

The varnish server is linked to the nginx container on port 80

To open the varnish version of a site, load it via :8080


---


## Persistent Data

1. Nginx has a virtual mount and read/write permission to your local vhosts directory. All changes are stored on your machine.

2. MySQL stores semi-persistent data within the vmware machine at /mnt/sda1/var/lib/mysql. The data will not be destroyed if the mysql container is destroyed, but will be destroyed if the vmware machine is destroyed.

