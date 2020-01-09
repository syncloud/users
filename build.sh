#!/bin/bash -xe

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd ${DIR}

if [[ -z "$2" ]]; then
    echo "usage $0 app version"
    exit 1
fi

NAME=$1
LDAPCHERRY_VERSION=1.1.1

ARCH=$(uname -m)
VERSION=$2

rm -rf ${DIR}/build
BUILD_DIR=${DIR}/build/${NAME}
mkdir -p ${BUILD_DIR}

wget --progress=dot:giga https://github.com/syncloud/3rdparty/releases/download/1/nginx-${ARCH}.tar.gz
tar xf nginx-${ARCH}.tar.gz
mv nginx ${BUILD_DIR}

wget --progress=dot:giga https://github.com/syncloud/3rdparty/releases/download/1/python-${ARCH}.tar.gz
tar xf python-${ARCH}.tar.gz
mv python ${BUILD_DIR}

${BUILD_DIR}/python/bin/pip install -r ${DIR}/requirements.txt

cp -r ${DIR}/bin ${BUILD_DIR}
cp -r ${DIR}/config ${BUILD_DIR}/config.templates
cp -r ${DIR}/hooks ${BUILD_DIR}

cd ${DIR}/build

wget --progress=dot:giga https://github.com/kakwa/ldapcherry/archive/${LDAPCHERRY_VERSION}.tar.gz
tar xzf ${LDAPCHERRY_VERSION}.tar.gz
cd ldapcherry-${LDAPCHERRY_VERSION}
${BUILD_DIR}/python/bin/pip install tempora==1.14.1
${BUILD_DIR}/python/bin/python setup.py install #--ptefix=${BUILD_DIR}/ldapcherry

mkdir ${DIR}/build/${NAME}/META
echo ${NAME} >> ${DIR}/build/${NAME}/META/app
echo ${VERSION} >> ${DIR}/build/${NAME}/META/version

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

PACKAGE=${NAME}_${VERSION}_${ARCH}.snap
echo ${PACKAGE} > ${DIR}/package.name
mksquashfs ${SNAP_DIR} ${DIR}/${PACKAGE} -noappend -comp xz -no-xattrs -all-root
