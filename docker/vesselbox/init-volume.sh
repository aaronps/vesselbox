#!/bin/sh
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
        echo arg is $1
        shift
esac done

# initial tests to ensure config and arguments are ok

test -z "$VOLUME_DIR" && { echo "volume dir cannot be empty"; exit 1; }
test -e "$VOLUME_DIR" || { echo "Volume $VOLUME_DIR does not exists"; exit 1; }
test -d "$VOLUME_DIR" || { echo "Volume $VOLUME_DIR is not a directory"; exit 1; }

# more data collection

VOLUME_HAS_DATA=$(find $VOLUME_DIR -maxdepth 0 ! -empty)


# final tests before running dangerous code

[[ "$VOLUME_HAS_DATA" && ! "$REINIT_OP" ]] && { echo "Volume at $VOLUME_DIR has data, use --reinit to delete data or --overwrite to just extract over it"; }


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
