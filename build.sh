#!/bin/bash -xe

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

NAME=users
LDAPCHERRY_VERSION=0.5.2
DOWNLOAD_URL=http://artifact.syncloud.org/3rdparty

if [[ -z "$1" ]]; then
    echo "usage $0 version"
    exit 1
fi

ARCH=$(uname -m)
VERSION=$1

if [ -n "$DRONE" ]; then
    echo "running under drone, removing coin cache"
    rm -rf ${DIR}/.coin.cache
fi

cd ${DIR}

rm -rf build
BUILD_DIR=${DIR}/build/${NAME}
mkdir -p ${BUILD_DIR}

coin --to ${BUILD_DIR} raw ${DOWNLOAD_URL}/nginx-${ARCH}.tar.gz
coin --to ${BUILD_DIR} raw ${DOWNLOAD_URL}/python-${ARCH}.tar.gz

${BUILD_DIR}/python/bin/pip install -r ${DIR}/requirements.txt

#cp -r ${DIR}/bin ${BUILD_DIR}
#cp -r ${DIR}/config ${BUILD_DIR}/config.templates
#cp -r ${DIR}/hooks ${BUILD_DIR}

cd ${BUILD_DIR}

mkdir META
echo ${NAME} >> META/app
echo ${VERSION} >> META/version

echo "getting latest diaspora source"
wget --progress=dot:giga https://github.com/kakwa/ldapcherry/archive/${LDAPCHERRY_VERSION}.tar.gz

tar xzf ${LDAPCHERRY_VERSION}.tar.gz

mv ldapcherry-${LDAPCHERRY_VERSION} ldapcherry
cd ldapcherry
${BUILD_DIR}/python/bin/python setup.py install

echo "snapping"
SNAP_DIR=${DIR}/build/snap
ARCH=$(dpkg-architecture -q DEB_HOST_ARCH)
rm -rf ${DIR}/*.snap
mkdir ${SNAP_DIR}
cp -r ${BUILD_DIR}/* ${SNAP_DIR}/
cp -r ${DIR}/snap/meta ${SNAP_DIR}/
cp ${DIR}/snap/snap.yaml ${SNAP_DIR}/meta/snap.yaml
echo "version: $VERSION" >> ${SNAP_DIR}/meta/snap.yaml
echo "architectures:" >> ${SNAP_DIR}/meta/snap.yaml
echo "- ${ARCH}" >> ${SNAP_DIR}/meta/snap.yaml

mksquashfs ${SNAP_DIR} ${DIR}/${NAME}_${VERSION}_${ARCH}.snap -noappend -comp xz -no-xattrs -all-root
