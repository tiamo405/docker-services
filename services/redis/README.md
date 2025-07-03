# Chỉ Redis
```sh
cd services/redis && docker-compose up -d
```

# test connection
```sh
./redis-manager.sh test
./redis-manager.sh cli
```
# remove cache
```sh
docker exec -it redis sh
redis-cli -a Gsht.2k24!@
FLUSHALL # xóa full
FLUSHDB # xóa 1 DB
```