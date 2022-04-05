#!/bin/bash -xe

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}

if [[ -z "$2" ]]; then
    echo "usage $0 app version"
    exit 1
fi

NAME=$1
LDAP_USER_MANAGER_VERSION=master

ARCH=$(uname -m)
VERSION=$2
DOWNLOAD_URL=https://github.com/syncloud/3rdparty/releases/download/1

apt update
apt install -y wget

BUILD_DIR=${DIR}/build/snap/app
mkdir -p ${BUILD_DIR}

cp -r ${DIR}/bin ${BUILD_DIR}
cp -r ${DIR}/config ${BUILD_DIR}
cp -r ${DIR}/hooks ${BUILD_DIR}

cd ${DIR}/build

wget --progress=dot:giga https://github.com/wheelybird/ldap-user-manager/archive/${LDAP_USER_MANAGER_VERSION}.tar.gz
tar xzf ${LDAP_USER_MANAGER_VERSION}.tar.gz
mv ldap-user-manager-${LDAP_USER_MANAGER_VERSION}/www ${BUILD_DIR}
