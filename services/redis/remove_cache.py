import redis

r = redis.Redis(host='localhost', port=6379, password='Gsht.2k24!@#')

# Xoá toàn bộ cache
r.flushall()

# Hoặc xoá 1 key cụ thể
r.delete('some:key')