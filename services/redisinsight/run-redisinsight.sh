#!/usr/bin/env bash
set -euo pipefail

# Đường dẫn dữ liệu trên host (sửa nếu cần)
DATA_DIR="../../data/redisinsight"

# Tên container
CONTAINER_NAME="redisinsight"

# Image có thể đổi sang tag ổn định nếu muốn: redis/redisinsight:2.54.0
IMAGE="redis/redisinsight:latest"

# Tạo thư mục dữ liệu nếu chưa có và đặt quyền an toàn cho container
mkdir -p "${DATA_DIR}"
# Thử quyền sở hữu 1000:1000 (phổ biến cho RedisInsight 2.x). Nếu gặp sự cố, có thể đổi 1001:1001.
sudo chown -R 1000:1000 "${DATA_DIR}"

# Dừng container cũ nếu đang chạy
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}\$"; then
  docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
fi

# Kéo image mới nhất (tùy chọn)
docker pull "${IMAGE}"

# Chạy container
docker run -d \
  --name "${CONTAINER_NAME}" \
  -p 5540:5540 \
  -e RI_ACCEPT_TERMS_AND_CONDITIONS=true \
  -v "${DATA_DIR}:/db" \
  --restart unless-stopped \
  "${IMAGE}"

echo "RedisInsight đang chạy tại http://localhost:5540"
