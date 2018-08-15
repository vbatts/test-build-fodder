#!/bin/bash
# Build a bash container that doesn't even include a package manager.
# Expects to be on a host with yum, as the builder-image was using centos.

set -ex

from=$(buildah from scratch)
scratchmnt=$(buildah mount ${from})

yum install \
    --installroot ${scratchmnt} \
    --release 7 \
    --setopt install_weak_deps=false -y \
    bash coreutils
yum clean \
    --installroot ${scratchmnt} \
    all
rm -rf ${scratchmnt}/var/cache/yum
buildah unmount ${from}
buildah config \
    --cmd /bin/bash \
    --created-by "${USER}@${HOSTNAME}" \
    ${from}
buildah commit ${from} ${1+"$@"}
