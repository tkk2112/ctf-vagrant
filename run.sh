#!/bin/bash

if [ -z "$1" ]; then
    echo "$ run.sh /path/to/shared/folder"
    exit 1
fi

docker run -v $1:/root/host-share --rm -it --privileged --workdir=/root garble/ctf
