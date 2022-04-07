#!/bin/bash -xe

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}

if [[ -z "$1" ]]; then
    echo "usage $0 version"
    exit 1
fi

VERSION=$1

ARCH=$(uname -m)
DOWNLOAD_URL=https://github.com/syncloud/3rdparty/releases/download/1

apt update
apt install -y wget

BUILD_DIR=${DIR}/build/snap
mkdir -p ${BUILD_DIR}

cp -r ${DIR}/bin ${BUILD_DIR}
cp -r ${DIR}/config ${BUILD_DIR}
cp -r ${DIR}/hooks ${BUILD_DIR}

cd ${DIR}/build

wget --progress=dot:giga https://github.com/wheelybird/ldap-user-manager/archive/${VERSION}.tar.gz
tar xzf ${VERSION}.tar.gz
mv ldap-user-manager-${VERSION}/www ${BUILD_DIR}
