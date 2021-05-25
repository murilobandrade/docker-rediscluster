#!/bin/bash

#redis_cli=$(docker run -it --link some-redis:redis --rm redis redis-cli -h redis -p 6379)

function redis_cli() {
	args="${@:3}"
        eval docker exec -it $1 redis-cli -p $2 $args
}

DOCKER_IP=$(ip addr show docker0 | grep 'inet ' |  awk '{ print $2}')

echo "DOCKER IP : $DOCKER_IP"

# create two redis instances
docker run --rm --name redis_0 -t -d -i redis:4.0 
docker run --rm --name redis_1 -t -d -i redis:4.0

#get master ip
REDIS_0_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' redis_0)
REDIS_1_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' redis_1)

echo "REDIS_0_IP : $REDIS_0_IP"
echo "REDIS_1_IP : $REDIS_1_IP"

# start up the sentinels
docker run --rm --name sentinel_0 -v $(pwd)/sentinel_0.conf:/srv/sentinel.conf -tdi redis:4.0 redis-sentinel /srv/sentinel.conf 
docker run --rm --name sentinel_1 -v $(pwd)/sentinel_1.conf:/srv/sentinel.conf -tdi redis:4.0 redis-sentinel /srv/sentinel.conf 
#docker run --name sentinel_2 -v $(pwd)/sentinel.conf:/srv/sentinel.conf -tdi redis:4.0 redis-sentinel /srv/sentinel.conf 

#get sentinel ips
SENTINEL_0_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' sentinel_0)
SENTINEL_1_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' sentinel_1)
#SENTINEL_2_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' sentinel_2)

echo "SENTINEL_0_IP : $SENTINEL_0_IP"
echo "SENTINEL_1_IP : $SENTINEL_1_IP"
#echo "SENTINEL_2_IP : $SENTINEL_2_IP"

redis_cli redis_1 6379 slaveof $REDIS_0_IP 6379

#redis_cli sentinel_0 26379 sentinel monitor testing $REDIS_0_IP 6379 2
#redis_cli sentinel_0 26379 sentinel set testing down-after-milliseconds 1000
#redis_cli sentinel_0 26379 sentinel set testing failover-timeout 1000
#redis_cli sentinel_0 26379 sentinel set testing parallel-syncs 1
#
#redis_cli sentinel_1 26379 sentinel monitor testing $REDIS_0_IP 6379 2
#redis_cli sentinel_1 26379 sentinel set testing down-after-milliseconds 1000
#redis_cli sentinel_1 26379 sentinel set testing failover-timeout 1000
#redis_cli sentinel_1 26379 sentinel set testing parallel-syncs 1
#
#redis_cli sentinel_2 26379 sentinel monitor testing $REDIS_0_IP 6379 2
#redis_cli sentinel_2 26379 sentinel set testing down-after-milliseconds 1000
#redis_cli sentinel_2 26379 sentinel set testing failover-timeout 1000
#redis_cli sentinel_2 26379 sentinel set testing parallel-syncs 
