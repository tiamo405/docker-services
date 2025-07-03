# Chỉ Redis
cd services/redis && docker-compose up -d

# Hoặc tất cả services
docker-compose up -d

# Hoặc dùng script
chmod +x redis-manager.sh
./redis-manager.sh start

# test connection
./redis-manager.sh test
./redis-manager.sh cli

# remove cache
docker exec -it redis redis-cli -a Gsht.2k24!@#
FLUSHALL # xóa full
FLUSHDB # xóa 1 DB