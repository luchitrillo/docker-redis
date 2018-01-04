# redis-cluster-docker-compose
**Redis cluster with Docker Compose**

Using Docker Compose to setup a redis cluster with sentinel.

## Prerequisite

Install [Docker][4] and [Docker Compose][3] in testing environment

**NOTE** If you are using Windows, please execute the following command before "git clone" to disable changing the line endings of script files into DOS format

```
git config --global core.autocrlf false
```

## Docker Compose template of Redis cluster

The template defines the topology of the Redis cluster

```
master:
  image: redis:3
  ports:
    - "4000:6379"
slave:
  image: redis:3
  command: redis-server --slaveof redis-master 6379
  links:
    - master:redis-master
sentinel:
  build: sentinel
  environment:
    - SENTINEL_DOWN_AFTER=5000
    - SENTINEL_FAILOVER=5000
  links:
    - master:redis-master
    - slave

```

There are following services in the cluster,

* Master: Redis master
* Slave:  Redis slave
* Sentinel: Redis sentinel


The sentinels are configured with a "mymaster" instance with the following properties -

```
sentinel monitor mymaster redis-master 6379 2
sentinel down-after-milliseconds mymaster 4000
sentinel parallel-syncs mymaster 1
sentinel failover-timeout mymaster 4000
```

The details could be found in sentinel/sentinel.conf

The default values of the environment variables for Sentinel are as following

* SENTINEL_QUORUM: 2
* SENTINEL_DOWN_AFTER: 30000
* SENTINEL_FAILOVER: 180000

## Play with it

Build the sentinel Docker image

```
docker-compose build
```

Start the redis cluster with the proper scale & check the redis cluster

```
docker-compose up -d --scale slave=2 --scale sentinel=3 && docker-compose ps
```

The result is

```
                Name                              Command               State           Ports
------------------------------------------------------------------------------------------------------
redisclusterdockercompose_master_1     docker-entrypoint.sh redis ...   Up      0.0.0.0:4000->6379/tcp
redisclusterdockercompose_sentinel_1   sentinel-entrypoint.sh           Up      26379/tcp, 6379/tcp
redisclusterdockercompose_sentinel_2   sentinel-entrypoint.sh           Up      26379/tcp, 6379/tcp
redisclusterdockercompose_sentinel_3   sentinel-entrypoint.sh           Up      26379/tcp, 6379/tcp
redisclusterdockercompose_slave_1      docker-entrypoint.sh redis ...   Up      6379/tcp
redisclusterdockercompose_slave_2      docker-entrypoint.sh redis ...   Up      6379/tcp
------------------------------------------------   
```

Check the status of redis cluster

```
docker-compose ps
```

Execute the test script
```
./test.sh
```
to simulate stop and recover the Redis master. And you will see the master is switched to slave automatically.

Or, you can do the test manually to pause/unpause redis server through

```
docker pause rediscluster_master_1
docker unpause rediscluster_master_1
```
And get the sentinel infomation with following commands

```
docker exec rediscluster_sentinel_1 redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster
```

## References

[https://github.com/mdevilliers/docker-rediscluster][1]
[https://registry.hub.docker.com/u/joshula/redis-sentinel/] [2]

[1]: https://github.com/mdevilliers/docker-rediscluster
[2]: https://registry.hub.docker.com/u/joshula/redis-sentinel/
[3]: https://docs.docker.com/compose/
[4]: https://www.docker.com
