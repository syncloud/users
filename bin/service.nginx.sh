#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )

/bin/rm -f /var/snap/users/common/web.socket
exec ${DIR}/nginx/sbin/nginx -c /var/snap/users/current/config/nginx.conf -p ${DIR}/nginx -e stderr
