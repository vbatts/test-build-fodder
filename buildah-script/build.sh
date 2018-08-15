#!/bin/bash
# Build a bash container that doesn't even include a package manager.
# Expects to be on a host with yum, as the builder-image was using centos.

set -ex

STORAGE_DRIVER=${STORAGE_DRIVER:-overlayfs}

from=$(buildah --storage-driver="${STORAGE_DRIVER}" from scratch)
scratchmnt=$(buildah --storage-driver="${STORAGE_DRIVER}" mount ${from})

yum install \
    -y \
    --installroot ${scratchmnt} \
    --releasever 7 \
    bash coreutils
yum clean \
    --installroot ${scratchmnt} \
    all
rm -rf ${scratchmnt}/var/cache/yum
buildah --storage-driver="${STORAGE_DRIVER}" unmount ${from}
buildah --storage-driver="${STORAGE_DRIVER}" config \
    --cmd /bin/bash \
    --created-by "${USER}@${HOSTNAME}" \
    ${from}
buildah --storage-driver="${STORAGE_DRIVER}" commit ${from} ${1+"$@"}
