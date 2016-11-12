#!/bin/bash

if [ -z "$1" ]; then
    echo "$ run.sh /path/to/shared/folder"
    exit 1
fi

docker run -v $1:/root/host-share -p 8022:22 -d --privileged --workdir=/root --name=ctf --rm garble/ctf

script=$(pwd)
echo ""
$script/docker-ssh
