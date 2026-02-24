#!/bin/sh
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

VOLUME_DIR=/data
TAR_FILE=/base.tar
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

    --help)
        echo "wants help"
        shift
        ;;

    *)
        echo "Unknown argument: $1"
        exit 1
        
esac done

# initial tests to ensure config and arguments are ok

test -z "$VOLUME_DIR" && { echo "volume dir cannot be empty"; exit 1; }
test -e "$VOLUME_DIR" || { echo "Volume $VOLUME_DIR does not exists"; exit 1; }
test -d "$VOLUME_DIR" || { echo "Volume $VOLUME_DIR is not a directory"; exit 1; }

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
tar -xC $VOLUME_DIR -f $TAR_FILE
echo "Extracting data... Done"
