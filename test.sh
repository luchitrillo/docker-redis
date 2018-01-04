SERVER_IP0=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' dockerredis_master_1)
SERVER_IP1=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' dockerredis_slave_1)
SERVER_IP2=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' dockerredis_slave_2)
SENTINEL_IP1=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' dockerredis_sentinel_1)
SENTINEL_IP2=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' dockerredis_sentinel_2)
SENTINEL_IP3=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' dockerredis_sentinel_3)
echo ------------------------------------------------
echo Redis Master: $SERVER_IP0
echo Redis Slave Replica: $SERVER_IP1
echo Redis Slave Replica: $SERVER_IP2
echo Redis Sentinel_1: $SENTINEL_IP1
echo Redis Sentinel_2: $SENTINEL_IP2
echo Redis Sentinel_3: $SENTINEL_IP3
echo ------------------------------------------------
echo "- Current sentinel status -"; echo ""
docker exec dockerredis_sentinel_1 redis-cli -p 26379 info Sentinel
echo ""; echo "# Current master"
docker exec dockerredis_sentinel_1 redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster
echo ------------------------------------------------
echo "Stopping redis current master (60 seconds)";echo ""
docker pause dockerredis_master_1
sleep 60
echo ------------------------------------------------
echo "- Current sentinel status -"; echo ""
docker exec dockerredis_sentinel_1 redis-cli -p 26379 info Sentinel
echo ""; echo "# Current master"
docker exec dockerredis_sentinel_1 redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster
echo ------------------------------------------------
echo "Restarting redis previous master as a slave & stopping redis current master (60 seconds)";echo ""
docker unpause dockerredis_master_1
docker pause dockerredis_slave_1
sleep 60
echo ------------------------------------------------
echo "- Current sentinel status -"; echo ""
docker exec dockerredis_sentinel_1 redis-cli -p 26379 info Sentinel
echo ""; echo "# Current master"
docker exec dockerredis_sentinel_1 redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster
echo ------------------------------------------------
echo "Restarting redis prevoius master as current slave (60 seconds)"; echo ""
docker unpause dockerredis_slave_1
sleep 60
echo ------------------------------------------------
echo "- Current sentinel status -"; echo ""
docker exec dockerredis_sentinel_1 redis-cli -p 26379 info Sentinel
echo ""; echo "# Current master"
docker exec dockerredis_sentinel_1 redis-cli -p 26379 SENTINEL get-master-addr-by-name mymaster
echo ------------------------------------------------

