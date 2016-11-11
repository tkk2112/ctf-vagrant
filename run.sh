#!/bin/bash

if [ -z "$1" ]; then
    echo "$ run.sh /path/to/shared/folder"
    exit 1
fi

docker run -v $1:/root/host-share --rm -t -i garble/ctf /sbin/my_init -- bash -l
