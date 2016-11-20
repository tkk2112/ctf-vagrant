#!/bin/bash

# delete all stopped containers
docker rm $(docker ps -a -q)
# delete untagged images
docker rmi $(docker images | grep "^<none>" | awk "{print $3}")

