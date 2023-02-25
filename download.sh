#!/bin/bash -ex

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}

ARCH=$(uname -m)
DOWNLOAD_URL=https://github.com/syncloud/3rdparty/releases/download/
VERSION=$1

BUILD_DIR=${DIR}/build/snap
mkdir -p $BUILD_DIR

apt update
apt -y install wget unzip

cd ${DIR}/build
wget -c --progress=dot:giga ${DOWNLOAD_URL}/nginx/nginx-${ARCH}.tar.gz
tar xf nginx-${ARCH}.tar.gz
mv nginx ${BUILD_DIR}

cd ${DIR}/build
#wget --progress=dot:giga https://github.com/wheelybird/ldap-user-manager/archive/${VERSION}.tar.gz
wget --progress=dot:giga https://github.com/cyberb/ldap-user-manager/archive/refs/heads/${VERSION}.tar.gz
tar xzf ${VERSION}.tar.gz
mv ldap-user-manager-${VERSION}/www ${BUILD_DIR}
