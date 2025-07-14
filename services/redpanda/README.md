# Redpanda Service với SASL Authentication

Redpanda là một streaming platform tương thích với Apache Kafka, được tối ưu hóa cho hiệu suất cao và dễ sử dụng.

## 📋 Tổng quan

- **Image**: `docker.redpanda.com/redpandadata/redpanda:v24.1.13`
- **Console**: `docker.redpanda.com/redpandadata/console:v2.6.1`
- **Mode**: Development Container
- **Authentication**: SASL SCRAM-SHA-256
- **Network**: Docker Bridge Network

## 🚀 Khởi động nhanh

### 1. Khởi động services
```bash
# Di chuyển đến thư mục redpanda
cd /home/server/docker-services/services/redpanda

# Khởi động tất cả services (sử dụng docker compose, không phải docker-compose)
docker compose up -d

# Kiểm tra trạng thái
docker compose ps
```

### 2. Chờ Redpanda khởi động
```bash
# Theo dõi logs để đảm bảo Redpanda đã sẵn sàng
docker compose logs -f redpanda

# Hoặc kiểm tra health status
docker compose ps
# Đợi đến khi thấy status "(healthy)"
```

### 3. Setup SASL Authentication
```bash
# Tạo SASL
docker exec redpanda-sasl rpk acl user create admin --password admin2k25 --api-urls localhost:9644
# # Tạo SASL user và topics
# chmod +x setup-sasl.sh
# ./setup-sasl.sh
```

### 4. Restart Console service (nếu cần)
```bash
# Console có thể cần restart để kết nối với SASL user vừa tạo
docker compose restart console

# Kiểm tra logs console
docker compose logs console
```

### 5. Truy cập Redpanda Console
- **URL**: `http://192.168.1.66:8080`
- **Topics page**: `http://192.168.1.66:8080/topics`
- **Brokers page**: `http://192.168.1.66:8080/brokers`

## 🔧 Cấu hình

### Ports Mapping
- **9223:9092**: Kafka API Internal (dành cho redpanda config)
- **9093:9093**: Kafka API External (dành cho redpanda_logic config)  
- **8080:8080**: Redpanda Console Web UI
- **8083:8083**: Pandaproxy (REST API)
- **8081:8081**: Schema Registry
- **9644:9644**: Admin API

### Cấu hình Network
- **External Access**: `192.168.1.66` (IP của server)
- **Internal Network**: `redpanda_network` (Docker bridge)
- **Advertise Addresses**: 
  - Internal: `192.168.1.66:9223`
  - External: `192.168.1.66:9093`

### SASL Authentication
- **Username**: `admin`
- **Password**: `admin2k25`
- **Mechanism**: `SCRAM-SHA-256`
- **Security Protocol**: `SASL_PLAINTEXT`

### Default Topics & Groups
- **Main Topic**: `gsht_topic_local_namtp` (3 partitions)
- **Logic Topic**: `gsht_logic_topic_local_namtp` (1 partition)
- **Consumer Groups**: 
  - `gsht_group_local`
  - `gsht_logic_group_local`

## 📱 Kết nối từ Application

### Cấu hình cho Redpanda Config (Internal)
```json
{
  "redpanda": {
    "bootstrap.servers": "192.168.1.66:9223",
    "key.serializer": "org.apache.kafka.common.serialization.StringSerializer",
    "value.serializer": "org.apache.kafka.common.serialization.StringSerializer", 
    "key.deserializer": "org.apache.kafka.common.serialization.StringDeserializer",
    "value.deserializer": "org.apache.kafka.common.serialization.StringDeserializer",
    "security.protocol": "SASL_PLAINTEXT",
    "sasl.mechanism": "SCRAM-SHA-256",
    "sasl.jaas.config": "org.apache.kafka.common.security.scram.ScramLoginModule required username=\"admin\" password=\"admin2k25\";",
    "group.id": "gsht_group_local",
    "auto.offset.reset": "earliest",
    "enable.auto.commit": "true",
    "topic": "gsht_topic_local_namtp"
  }
}
```

### Cấu hình cho Redpanda Logic (External)
```json
{
  "redpanda_logic": {
    "bootstrap.servers": "192.168.1.66:9093",
    "key.serializer": "org.apache.kafka.common.serialization.StringSerializer",
    "value.serializer": "org.apache.kafka.common.serialization.StringSerializer",
    "key.deserializer": "org.apache.kafka.common.serialization.StringDeserializer", 
    "value.deserializer": "org.apache.kafka.common.serialization.StringDeserializer",
    "max.request.size": "8388608",
    "security.protocol": "SASL_PLAINTEXT",
    "sasl.mechanism": "SCRAM-SHA-256",
    "sasl.jaas.config": "org.apache.kafka.common.security.scram.ScramLoginModule required username=\"admin\" password=\"admin2k25\";",
    "group.id": "gsht_logic_group_local",
    "auto.offset.reset": "earliest", 
    "enable.auto.commit": "true",
    "topic": "gsht_logic_topic_local_namtp"
  }
}
```

### Java/Spring Boot Properties
```properties
# Redpanda Config
spring.kafka.bootstrap-servers=192.168.1.66:9223
spring.kafka.security.protocol=SASL_PLAINTEXT
spring.kafka.properties.sasl.mechanism=SCRAM-SHA-256
spring.kafka.properties.sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="admin" password="admin2k25";
spring.kafka.consumer.group-id=gsht_group_local
spring.kafka.consumer.auto-offset-reset=earliest
```

### Python (kafka-python)
```python
from kafka import KafkaProducer, KafkaConsumer

# Producer cho redpanda config  
producer = KafkaProducer(
    bootstrap_servers=['192.168.1.66:9223'],
    security_protocol='SASL_PLAINTEXT',
    sasl_mechanism='SCRAM-SHA-256',
    sasl_plain_username='admin',
    sasl_plain_password='admin2k25'
)

# Consumer cho redpanda logic
consumer = KafkaConsumer(
    'gsht_logic_topic_local_namtp',
    bootstrap_servers=['192.168.1.66:9093'],
    security_protocol='SASL_PLAINTEXT',
    sasl_mechanism='SCRAM-SHA-256', 
    sasl_plain_username='admin',
    sasl_plain_password='admin2k25',
    group_id='gsht_logic_group_local',
    auto_offset_reset='earliest'
)
```

### Node.js (kafkajs)
```javascript
const { Kafka } = require('kafkajs');

// Redpanda Logic config
const kafka = Kafka({
  clientId: 'my-app',
  brokers: ['192.168.1.66:9093'],
  sasl: {
    mechanism: 'scram-sha-256',
    username: 'admin',
    password: 'admin2k25'
  }
});
```

## 🛠️ Quản lý và Monitoring

### RPK Command Line Interface
```bash
# Vào container để sử dụng rpk
docker exec -it redpanda-sasl bash

# Cluster info với SASL auth
docker exec redpanda-sasl rpk cluster info --brokers localhost:9092 --user admin --password admin2k25 --sasl-mechanism SCRAM-SHA-256

# List topics
docker exec redpanda-sasl rpk topic list --brokers localhost:9092 --user admin --password admin2k25 --sasl-mechanism SCRAM-SHA-256

# Tạo topic mới  
docker exec redpanda-sasl rpk topic create my-new-topic --partitions 3 --replicas 1 --brokers localhost:9092 --user admin --password admin2k25 --sasl-mechanism SCRAM-SHA-256

# Produce message
docker exec -it redpanda-sasl rpk topic produce gsht_topic_local_namtp --brokers localhost:9092 --user admin --password admin2k25 --sasl-mechanism SCRAM-SHA-256

# Consume messages
docker exec redpanda-sasl rpk topic consume gsht_topic_local_namtp --group gsht_group_local --brokers localhost:9092 --user admin --password admin2k25 --sasl-mechanism SCRAM-SHA-256

# Xem consumer groups
docker exec redpanda-sasl rpk group list --brokers localhost:9092 --user admin --password admin2k25 --sasl-mechanism SCRAM-SHA-256

# Xem ACLs  
docker exec redpanda-sasl rpk acl list --brokers localhost:9092 --user admin --password admin2k25 --sasl-mechanism SCRAM-SHA-256
```

### Docker Compose Commands
```bash
# Kiểm tra trạng thái services
docker compose ps

# Xem logs
docker compose logs redpanda
docker compose logs console  

# Restart services
docker compose restart redpanda
docker compose restart console

# Stop/Start
docker compose down
docker compose up -d
```

## 🎯 Redpanda Console UI

Truy cập **http://192.168.1.66:8080** để sử dụng:

### Dashboard
- Cluster overview
- Broker status: `192.168.1.66:9223` và `192.168.1.66:9093`
- Topic metrics
- Consumer group status

### Topics Management
- **URL**: `http://192.168.1.66:8080/topics`
- View topics: `gsht_topic_local_namtp`, `gsht_logic_topic_local_namtp`
- Create/Delete topics
- View messages và partition details
- Topic configuration

### Consumer Groups  
- **URL**: `http://192.168.1.66:8080/groups`
- Group status: `gsht_group_local`, `gsht_logic_group_local`
- Lag monitoring
- Member details
- Offset management

### Brokers
- **URL**: `http://192.168.1.66:8080/brokers`
- Broker configurations
- Partition distribution
- Health status

## 🐛 Troubleshooting

### Kiểm tra trạng thái services
```bash
# Kiểm tra containers
docker compose ps

# Xem logs chi tiết
docker compose logs redpanda
docker compose logs console

# Kiểm tra health
docker exec redpanda-sasl rpk cluster health
```

### Test connectivity
```bash
# Test HTTP endpoints
curl http://192.168.1.66:8080
curl http://192.168.1.66:9644/v1/status/ready

# Test Kafka connection từ bên ngoài
docker exec redpanda-sasl rpk cluster info --brokers localhost:9092 --user admin --password admin2k25 --sasl-mechanism SCRAM-SHA-256
```

### Common Issues

1. **Console không load được (http://192.168.1.66:8080)**
   ```bash
   # Chờ Redpanda khởi động hoàn tất (15-30s)
   docker compose logs redpanda -f
   
   # Kiểm tra console logs
   docker compose logs console
   
   # Restart console nếu cần
   docker compose restart console
   ```

2. **SASL Authentication failed**
   ```bash
   # Tạo lại user admin
   docker exec redpanda-sasl rpk acl user create admin --password admin2k25 --api-urls localhost:9644
   
   # Chạy lại setup script
   ./setup-sasl.sh
   
   # Kiểm tra user đã tạo
   docker exec redpanda-sasl rpk acl user list --api-urls localhost:9644
   ```

3. **UnknownHostException: redpanda**
   - **✅ ĐÃ SỬA**: Sử dụng IP `192.168.1.66` thay vì hostname `redpanda`
   - Advertise addresses đã được cập nhật để sử dụng IP thực

4. **Topic không tạo được**
   ```bash
   # Kiểm tra quyền admin
   docker exec redpanda-sasl rpk acl list --brokers localhost:9092 --user admin --password admin2k25 --sasl-mechanism SCRAM-SHA-256
   
   # Grant permissions
   docker exec redpanda-sasl rpk acl create --allow-principal User:admin --operation all --topic '*' --brokers localhost:9092 --user admin --password admin2k25 --sasl-mechanism SCRAM-SHA-256
   ```

5. **Console không kết nối được Kafka**
   ```bash
   # Console cần restart sau khi tạo SASL user
   docker compose restart console
   
   # Kiểm tra console config trong logs
   docker compose logs console | grep -i kafka
   ```

### Reset toàn bộ (nếu gặp vấn đề nghiêm trọng)
```bash
# Stop và xóa containers
docker compose down -v

# Xóa data (cẩn thận!)
sudo rm -rf ~/docker-services/data/redpanda/*

# Khởi động lại từ đầu
docker compose up -d
sleep 30
./setup-sasl.sh
docker compose restart console
```

## ✅ Trạng thái Setup Hiện Tại

### 🎯 **Đã Hoạt động Thành Công:**
- **Redpanda**: ✅ Healthy với SASL authentication
- **Console UI**: ✅ Hoạt động tại `http://192.168.1.66:8080`
- **Kafka API Internal**: ✅ `192.168.1.66:9223` (với SASL)
- **Kafka API External**: ✅ `192.168.1.66:9093` (với SASL)
- **Topics**: ✅ `gsht_topic_local_namtp`, `gsht_logic_topic_local_namtp`
- **Consumer Groups**: ✅ `gsht_group_local`, `gsht_logic_group_local`
- **Admin User**: ✅ `admin/admin2k25` với SCRAM-SHA-256

### 🔧 **Các vấn đề đã được sửa:**
1. **UnknownHostException**: Sử dụng IP `192.168.1.66` thay vì hostname `redpanda`
2. **SASL Authentication**: Đã enable và setup user admin
3. **Port Configuration**: Đã mapping đúng ports và advertise addresses
4. **Console Connection**: Đã kết nối thành công với Kafka cluster
5. **Docker Compose**: Sử dụng `docker compose` thay vì legacy `docker-compose`

### 🚀 **Ready to Use:**
- Truy cập Console: `http://192.168.1.66:8080/topics`
- Cấu hình application với IP `192.168.1.66` ports `9223`/`9093`
- SASL credentials: `admin/admin2k25`

---

## 📚 Tài liệu tham khảo

- [Redpanda Documentation](https://docs.redpanda.com/)
- [Redpanda Console](https://github.com/redpanda-data/console)
- [Kafka API Compatibility](https://docs.redpanda.com/docs/reference/kafka-compatibility/)
- [RPK CLI Reference](https://docs.redpanda.com/docs/reference/rpk/)

## 📊 Performance Tuning (Tùy chọn)

### Memory Settings
```yaml
# Trong docker-compose.yml - để tăng performance cho production
command:
  - --memory 2G  # Tăng memory (hiện tại: 1G)
  - --smp 2      # Tăng CPU cores (hiện tại: 1)
```

### Volume Performance  
```yaml
# Sử dụng SSD hoặc NVMe để tăng I/O performance
volumes:
  - redpanda-data:/var/lib/redpanda/data
  # Hiện tại sử dụng Docker managed volume
```

## 🔐 Security Notes

⚠️ **Quan trọng cho Production:**
- **Password mặc định**: `admin2k25` - **Cần thay đổi cho production**
- **SASL_PLAINTEXT**: Chỉ phù hợp cho development, production nên dùng SSL
- **Console UI**: Không có authentication - cần reverse proxy/auth cho production
- **Network**: Hiện tại expose trên `0.0.0.0`, production nên restrict IP ranges

### Thay đổi password cho Production:
```bash
# Tạo user mới với password mạnh
docker exec redpanda-sasl rpk acl user create myuser --password 'StrongP@ssw0rd!' --api-urls localhost:9644

# Xóa default admin user
docker exec redpanda-sasl rpk acl user delete admin --api-urls localhost:9644
```
