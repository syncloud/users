#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

exec $DIR/php/bin/php-fpm.sh -y /var/snap/users/current/config/php-fpm.conf -c /var/snap/users/current/config/php.ini
