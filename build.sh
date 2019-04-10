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

DOWNLOAD_URL=http://artifact.syncloud.org/3rdparty

rm -rf ${DIR}/build
BUILD_DIR=${DIR}/build/${NAME}
mkdir -p ${BUILD_DIR}

coin --to ${BUILD_DIR} raw ${DOWNLOAD_URL}/nginx-${ARCH}.tar.gz
coin --to ${BUILD_DIR} raw ${DOWNLOAD_URL}/python-${ARCH}.tar.gz
${BUILD_DIR}/python/bin/pip install -r ${DIR}/requirements.txt

#apt-get install libyaml-dev

#cp -r ${DIR}/bin ${BUILD_DIR}
#cp -r ${DIR}/config ${BUILD_DIR}/config.templates
#cp -r ${DIR}/hooks ${BUILD_DIR}

cd ${BUILD_DIR}

echo "getting latest diaspora source"
wget --progress=dot:giga https://github.com/kakwa/ldapcherry/archive/${LDAPCHERRY_VERSION}.tar.gz

tar xzf ${LDAPCHERRY_VERSION}.tar.gz

mv ldapcherry-${LDAPCHERRY_VERSION} ldapcherry
cd ldapcherry
#sed -i 's/CherryPy >= 3.0.0/CherryPy >= 3.0.0, < 18.0.0/g' setup.py
${BUILD_DIR}/python/bin/python setup.py install

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
