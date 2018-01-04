import time
from redis.sentinel import Sentinel

sentinel = Sentinel([('172.17.0.5', 26379),('172.17.0.7', 26379),('172.17.0.8', 26379)], socket_timeout=0.1)
for i in range(1,1000):
  print "cicle " + str(i)
  try:
    print "master: " + str(sentinel.discover_master('mymaster'))
    print "slave/s: " + str(sentinel.discover_slaves('mymaster'))
    master = sentinel.master_for('mymaster', socket_timeout=0.1)
    slave = sentinel.slave_for('mymaster', socket_timeout=0.1)
  except:
    print "sentinel choosing a master"
  key = "key " + str(i)
  value = "value " + str(i)
  try:
    print "master.set " + key + " " + value 
    master.set(key, value)
    print "master.get " + key + " = " + str(master.get(key))
    print "master.set " + key + " = " + str(slave.get(key))
    #print "master.delete " + key
    #master.delete(key)
  except:
    print "cluster read-only"
  print ""
  time.sleep(1)
