# Chỉ Redis
```sh
cd services/redis && docker-compose up -d
```

# test connection
```sh
./redis-manager.sh test
./redis-manager.sh cli
```
# join DB
```sh
docker exec -it redis sh
redis-cli -a Gsht.2k24!@
```
# remove cache
```sh
FLUSHALL # xóa full
FLUSHDB # xóa 1 DB
```
# check memory
```sh
info memory | grep maxmemory
Kết quả mong muốn:
maxmemory:0 # max ram
```