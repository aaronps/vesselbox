#!/bin/bash
# Copyright 2026 Aaron Perez Sanchez <aaronperezsanchez@hotmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

VOLUME_DIR="${VOLUME_DIRT:-/data}"
REINIT_OP=

while [ $# -ge 1 ]; do case $1 in

    --reinit)
        REINIT_OP=clean
        shift
        ;;

    --overwrite)
        REINIT_OP=overwrite
        shift
        ;;

    --volume=*)
        VOLUME_DIR="${1#*=}"
        shift
        ;;

    --volume)
        [ $# -lt 2 ] && { echo "--volume requires argument"; exit 1; }
        VOLUME_DIR="$2"
        shift 2
        ;;

    --insecure)
        SRC_REGISTRY_INSECURE=--insecure
        shift
        ;;

    --registry=*)
        SRC_TYPE=registry
        SRC="${1#*=}"
        shift
        ;;

    --registry)
        [ $# -lt 2 ] && { echo "--registry requires argument"; exit 1; }
        SRC_TYPE=registry
        SRC=$2
        shift 2
        ;;

    --image=*)
        SRC_TYPE=imagefile
        SRC="${1#*=}"
        shift
        ;;

    --image)
        [ $# -lt 2 ] && { echo "--image requires argument"; exit 1; }
        SRC_TYPE=imagefile
        SRC=$2
        shift 2
        ;;
    
    --rootfs=*)
        SRC_TYPE=rootfs
        SRC="${1#*=}"
        shift
        ;;

    --rootfs)
        [ $# -lt 2 ] && { echo "--rootfs requires argument"; exit 1; }
        SRC_TYPE=rootfs
        SRC=$2
        shift 2
        ;;

    --help)
        echo "Usage: $(basename $0) [OPTIONS]"
        echo ""
        echo "Initialize a volume with a root filesystem from various sources."
        echo ""
        echo "Options:"
        echo "  --reinit              Delete existing volume data before extracting"
        echo "  --overwrite           Extract over existing volume data (may cause issues)"
        echo "  --volume=PATH         Volume mount point (default: /data)"
        echo "  --volume PATH         Volume mount point (alternative form)"
        echo "  --insecure            Allow insecure registry connections"
        echo "  --registry=URL        Pull and extract image from a container registry"
        echo "  --registry URL        Pull and extract image from a registry (alternative form)"
        echo "  --image=PATH          Extract from a local container image file"
        echo "  --image PATH          Extract from a local image file (alternative form)"
        echo "  --rootfs=PATH         Extract from a rootfs tarball"
        echo "  --rootfs PATH         Extract from a rootfs tarball (alternative form)"
        echo "  --help                Show this help message"
        echo ""
        echo "Examples:"
        echo "  $(basename $0) --volume=/mnt/data --registry=myregistry.com/myimage:latest"
        echo "  $(basename $0) --volume=/data --rootfs=/path/to/rootfs.tar.gz --reinit"
        echo "  $(basename $0) --image=/path/to/image.tar --overwrite"
        exit 0
        ;;

    *)
        echo "Unknown argument: $1"
        exit 1
        
esac done

# initial tests to ensure config and arguments are ok
pre_checks() {
    test -z "$VOLUME_DIR" && { echo "volume dir cannot be empty"; exit 1; }
    test -e "$VOLUME_DIR" || { echo "Volume $VOLUME_DIR does not exists"; exit 1; }
    test -d "$VOLUME_DIR" || { echo "Volume $VOLUME_DIR is not a directory"; exit 1; }
    
    test -n "$SRC" || { echo "Source not set (SRC)"; exit 1; }
    case "$SRC_TYPE" in
        registry|imagefile|rootfs)
            ;;
        *)
            echo "Source type not set or invalid: registry, imagefile or rootfs"
            exit 1
            ;;
    esac
}

config_ssh() {
    echo "Configuring ssh to allow root login"
    mkdir -p $VOLUME_DIR/etc/ssh/sshd_config.d
    echo "PermitRootLogin yes" > $VOLUME_DIR/etc/ssh/sshd_config.d/vesselbox.conf
}

setup_root_password() {
    echo "Setting root password"
    
    PASS1=""
    PASS2=""

    while [ -z "$PASS1" ]; do
        read -s -p "Enter root password: " PASS1
        echo ""
        test -n "$PASS1" || echo "Password cannot be empty"
    done

    while [ "$PASS1" != "$PASS2" ]; do
        read -s -p "Verify root password: " PASS2
        echo ""
        test "$PASS1" == "$PASS2" || echo "Passwords are different, retry"
    done

    echo "root:$PASS1" | chpasswd -R $VOLUME_DIR || { echo "Root password update failed"; exit 1; }
}

pre_checks


# more data collection

VOLUME_HAS_DATA=$(find $VOLUME_DIR -maxdepth 0 ! -empty)


# final tests before running dangerous code

[[ "$VOLUME_HAS_DATA" && ! "$REINIT_OP" ]] && { echo "Volume at $VOLUME_DIR has data, use --reinit to delete data or --overwrite to just extract over it"; exit 1; }


# execute!

[[ "$VOLUME_HAS_DATA" ]] && case "$REINIT_OP" in
    clean)
        echo "Deleting old volume data..."
        find $VOLUME_DIR -mindepth 1 -delete
        echo "Deleting old volume data... Done"
        ;;
    overwrite)
        echo "WARNING: Base image will be extracted over old data, bad things may happen later"
        ;;
esac

echo "Extracting data..."

case $SRC_TYPE in
    registry)
        crane export $SRC_REGISTRY_INSECURE $SRC - | tar -xC $VOLUME_DIR
        ;;
    image)
        crane export - - < $SRC | tar -xC $VOLUME_DIR
        ;;
    rootfs)
        tar -xC $VOLUME_DIR -f $SRC
        ;;
esac

echo "Extracting data... Done"

config_ssh
setup_root_password
