# Redpanda Service

Redpanda là một streaming platform tương thích với Apache Kafka, được tối ưu hóa cho hiệu suất cao và dễ sử dụng.

## 📋 Tổng quan

- **Image**: `docker.redpanda.com/redpandadata/redpanda:latest`
- **Console**: `docker.redpanda.com/redpandadata/console:latest`
- **Mode**: Development Container
- **Authentication**: SASL SCRAM-SHA-256

## 🚀 Khởi động nhanh

### 1. Khởi động services
```bash
# Từ thư mục services/redpanda
docker-compose up -d

# Hoặc từ thư mục root
cd ~/docker-services && ./redpanda-manager.sh start
```

### 2. Setup SASL Authentication
```bash
# Chờ Redpanda khởi động hoàn tất (khoảng 15-20 giây)
chmod +x setup-sasl.sh
./setup-sasl.sh

# Hoặc từ thư mục root
./redpanda-manager.sh setup
```

### 3. Truy cập Console UI
Mở trình duyệt: **http://localhost:8080**

## 🔧 Cấu hình

### Ports
- **9223**: Kafka API (External) - Dùng để connect từ application
- **9092**: Kafka API (Internal) - Communication giữa containers
- **8080**: Console Web UI
- **8083**: Pandaproxy (REST API)
- **8084**: Schema Registry
- **9644**: Admin API

### Authentication
- **Username**: `admin`
- **Password**: `admin2k25`
- **Mechanism**: `SCRAM-SHA-256`
- **Security Protocol**: `SASL_PLAINTEXT`

### Default Topic & Group
- **Topic**: `gsht_topic_local_namtp`
- **Consumer Group**: `gsht_group_local`
- **Partitions**: 3
- **Replicas**: 1

## 📱 Kết nối từ Application

### Java/Spring Boot
```properties
spring.kafka.bootstrap-servers=localhost:9223
spring.kafka.security.protocol=SASL_PLAINTEXT
spring.kafka.properties.sasl.mechanism=SCRAM-SHA-256
spring.kafka.properties.sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="admin" password="admin2k25";
spring.kafka.consumer.group-id=gsht_group_local
spring.kafka.consumer.auto-offset-reset=earliest
```

### Python (kafka-python)
```python
from kafka import KafkaProducer, KafkaConsumer

producer = KafkaProducer(
    bootstrap_servers=['localhost:9223'],
    security_protocol='SASL_PLAINTEXT',
    sasl_mechanism='SCRAM-SHA-256',
    sasl_plain_username='admin',
    sasl_plain_password='admin2k25'
)

consumer = KafkaConsumer(
    'gsht_topic_local_namtp',
    bootstrap_servers=['localhost:9223'],
    security_protocol='SASL_PLAINTEXT',
    sasl_mechanism='SCRAM-SHA-256',
    sasl_plain_username='admin',
    sasl_plain_password='admin2k25',
    group_id='gsht_group_local',
    auto_offset_reset='earliest'
)
```

### Node.js (kafkajs)
```javascript
const { Kafka } = require('kafkajs');

const kafka = Kafka({
  clientId: 'my-app',
  brokers: ['localhost:9223'],
  sasl: {
    mechanism: 'scram-sha-256',
    username: 'admin',
    password: 'admin2k25'
  }
});
```

## 🛠️ Quản lý và Monitoring

### Command Line Interface (rpk)
```bash
# Vào container để sử dụng rpk
docker exec -it redpanda bash

# Xem cluster info
rpk cluster info

# List topics
rpk topic list

# Tạo topic mới
rpk topic create my-new-topic --partitions 3 --replicas 1

# Produce message
rpk topic produce gsht_topic_local_namtp

# Consume messages
rpk topic consume gsht_topic_local_namtp --group gsht_group_local

# Xem consumer groups
rpk group list

# Xem ACLs
rpk acl list
```

### Management Script
```bash
# Từ thư mục root project
./redpanda-manager.sh {command}

# Available commands:
./redpanda-manager.sh start          # Khởi động services
./redpanda-manager.sh stop           # Dừng services
./redpanda-manager.sh restart        # Restart services
./redpanda-manager.sh setup          # Setup SASL
./redpanda-manager.sh topic-list     # List topics
./redpanda-manager.sh topic-create mytopic  # Tạo topic
./redpanda-manager.sh consumer-groups # List consumer groups
./redpanda-manager.sh cluster-info   # Cluster info
./redpanda-manager.sh logs           # Xem logs
```

## 🎯 Console UI Features

Truy cập **http://localhost:8080** để sử dụng:

### Dashboard
- Cluster overview
- Topic metrics
- Consumer group status
- Partition distribution

### Topics Management
- Create/Delete topics
- View messages
- Topic configuration
- Partition details

### Consumer Groups
- Group status
- Lag monitoring
- Member details
- Offset management

### Schema Registry
- Schema management
- Version control
- Compatibility settings

## 🐛 Troubleshooting

### Kiểm tra trạng thái services
```bash
docker-compose ps
docker logs redpanda
docker logs redpanda-console
```

### Health check
```bash
# Kiểm tra Redpanda health
docker exec redpanda rpk cluster info

# Test connectivity
curl http://localhost:9644/v1/status/ready
```

### Common Issues

1. **Console không load được**
   - Chờ Redpanda khởi động hoàn tất (15-20s)
   - Kiểm tra logs: `docker logs redpanda-console`

2. **SASL Authentication failed**
   - Chạy lại setup: `./setup-sasl.sh`
   - Kiểm tra user đã tạo: `docker exec redpanda rpk acl user list`

3. **Topic không tạo được**
   - Kiểm tra quyền admin: `docker exec redpanda rpk acl list`
   - Tạo lại user admin nếu cần

### Reset toàn bộ
```bash
# Stop và xóa containers
docker-compose down -v

# Xóa data (cẩn thận!)
rm -rf ~/docker-services/data/redpanda/*

# Khởi động lại
docker-compose up -d
./setup-sasl.sh
```

## 📊 Performance Tuning

### Memory Settings
```yaml
# Trong docker-compose.yml
command:
  - --memory 2G  # Tăng memory cho production
  - --smp 2      # Tăng CPU cores
```

### Storage
```yaml
volumes:
  - ~/docker-services/data/redpanda:/var/lib/redpanda/data
  # Sử dụng SSD để tăng hiệu suất I/O
```

## 📚 Tài liệu tham khảo

- [Redpanda Documentation](https://docs.redpanda.com/)
- [Redpanda Console](https://github.com/redpanda-data/console)
- [Kafka API Compatibility](https://docs.redpanda.com/docs/reference/kafka-compatibility/)
- [RPK CLI Reference](https://docs.redpanda.com/docs/reference/rpk/)

## 🔐 Security Notes

- Password mặc định: `admin2k25` - Nên thay đổi cho production
- SASL được enable, không sử dụng plaintext cho production
- Console UI không có authentication - cần reverse proxy cho production
