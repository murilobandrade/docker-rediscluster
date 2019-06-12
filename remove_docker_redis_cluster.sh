#!/bin/bash
docker rm -v -f redis_0
docker rm -v -f redis_1

docker rm -v -f sentinel_0
docker rm -v -f sentinel_1
docker rm -v -f sentinel_2

#dangerous!
#docker volume ls | awk '{ print $2}' | xargs docker volume rm
docker volume ls | awk '{ print $2}' | xargs echo
