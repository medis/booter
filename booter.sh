#!/bin/bash

{ # this ensures the entire script is downloaded #

if [ -z "$SITENAME" ]; then
  SITENAME="website"
fi

if [ -z "$DOMAIN" ]; then
  DOMAIN="website"
fi

if [ -z "$PASSWORD" ]; then
  PASSWORD='123456789!'
fi

if [ -z "$IPADDRESS" ]; then
  IPADDRESS=""
fi

# Check server to install.
# Default to apache.
if [ -z "$SERVER" ] || [ $SERVER != "apache" ] || [ $SERVER != "nginx" ]; then
  SERVER="apache"
fi

# Check PHP version to install.
# Default to php 5.6 (Debian Jessie).
if [ -z "$PHP" ] || [ $PHP != "7.0" ]; then
  PHP="5.6"
fi

# Common tasks for both servers.
echo "****************** Install prerequisites ******************"
# software-properties-common - for apt-key command;
# lsb_release package - to get codename;
# git-core - to clone stuff from git;
apt-get install software-properties-common lsb-release git-core curl iptables  build-essential openssl apt-show-versions libapache2-mod-evasive sed -y

CODENAME="$(lsb_release -sc)"

# Export vars to external scripts.
export $PASSWORD
export $IPADDRESS
export $DOMAIN
export $SITENAME
export $PHP
export $CODENAME

# add non-free repository. At the moment for libapache2-mod-fastcgi.
add-apt-repository "http://http.us.debian.org/debian main non-free"

echo "****************** Creating site folder ******************"

# create project folder
mkdir "/var/www/$SITENAME/"
mkdir "/var/www/$SITENAME/logs"
chown www-data:www-data "/var/www/$SITENAME/logs"

echo "****************** Updating server software ******************"

# update / upgrade
apt-get update
apt-get -y upgrade

echo "****************** Installing MySql software ******************"

sh ./components/mysql.sh

echo "****************** Installing PHP5-FPM ******************"

sh ./components/php.sh

echo "****************** Installing Composer software ******************"

# install Composer
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

echo "****************** Setting up IPTABLES ******************"

sh ./components/firewall.sh

# Apache install instructions.
if [ $SERVER == 'apache' ]; then

sh ./components/apache.sh

# Nginx install instructions.
elif [ $SERVER == 'nginx' ]; then

sh ./components/nginx.sh

fi

# Install Drush
if [ -n "$DRUSH" ]; then

# Download latest stable release using the code below or browse to github.com/drush-ops/drush/releases.
wget http://files.drush.org/drush.phar
# Or use our upcoming release: wget http://files.drush.org/drush-unstable.phar

# Test your install.
php drush.phar core-status

# Rename to `drush` instead of `php drush.phar`. Destination can be anywhere on $PATH.
chmod +x drush.phar
sudo mv drush.phar /usr/local/bin/drush

# Enrich the bash startup file with completion and aliases.
drush init

fi
} # this ensures the entire script is downloaded #
