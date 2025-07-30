# RabbitMQ Message Broker Setup

RabbitMQ là một message broker mạnh mẽ, hỗ trợ nhiều messaging protocol và pattern.

## Thông tin kết nối

### Thông tin cơ bản
- **Host**: 127.0.0.1 (hoặc localhost)
- **AMQP Port**: 5673
- **Management UI Port**: 15673
- **Username**: admin
- **Password**: admin123
- **Default Virtual Host**: /

### Ports được expose
- `5673`: AMQP protocol port (kết nối từ application)
- `15673`: Management UI (Web interface)

## Cách sử dụng

### Khởi động RabbitMQ
```bash
cd /home/namtp/docker-services/services/rabbitmq
docker compose up -d
```

### Kiểm tra logs
```bash
docker compose logs -f rabbitmq
```

### Truy cập Management UI
Mở trình duyệt và truy cập: http://localhost:15673
- Username: admin
- Password: admin123

### Dừng service
```bash
docker compose down
```

## Lưu trữ dữ liệu

### Thư mục data được mount:
- **Data**: `../../data/rabbitmq/` → `/var/lib/rabbitmq`

Tất cả dữ liệu RabbitMQ (queues, exchanges, messages, users, etc.) được lưu persistent trong thư mục `data/rabbitmq/` trên host machine.

## Cấu hình file

### rabbitmq.conf
Cấu hình chính của RabbitMQ:
- User mặc định: admin/admin123
- Memory limit: 40% RAM
- Logging configuration
- Management plugin settings

### definitions.json
Cấu hình khởi tạo tự động:
- Virtual hosts: /, dev, test
- Sample queues và exchanges
- User permissions
- Policies

## Virtual Hosts đã tạo sẵn

1. **/** - Default vhost
2. **dev** - Development environment
3. **test** - Testing environment

## Sample Entities

### Queues
- `sample.queue` (vhost: /)
- `task.queue` (vhost: dev)

### Exchanges
- `sample.exchange` (vhost: /, type: direct)
- `task.exchange` (vhost: dev, type: topic)

## Kết nối từ code

### Python (sử dụng pika)
```python
import pika

# Basic connection
connection = pika.BlockingConnection(
    pika.ConnectionParameters(
        host='localhost',
        port=5673,
        virtual_host='/',
        credentials=pika.PlainCredentials('admin', 'admin123')
    )
)
channel = connection.channel()

# Declare queue
channel.queue_declare(queue='hello', durable=True)

# Send message
channel.basic_publish(
    exchange='',
    routing_key='hello',
    body='Hello World!',
    properties=pika.BasicProperties(delivery_mode=2)  # Persistent
)

connection.close()
```

### Node.js (sử dụng amqplib)
```javascript
const amqp = require('amqplib');

async function connect() {
    const connection = await amqp.connect({
        protocol: 'amqp',
        hostname: 'localhost',
        port: 5673,
        username: 'admin',
        password: 'admin123',
        vhost: '/'
    });
    
    const channel = await connection.createChannel();
    
    // Declare queue
    await channel.assertQueue('hello', { durable: true });
    
    // Send message
    channel.sendToQueue('hello', Buffer.from('Hello World!'), {
        persistent: true
    });
    
    await connection.close();
}
```

### Java (sử dụng RabbitMQ Java Client)
```java
import com.rabbitmq.client.ConnectionFactory;
import com.rabbitmq.client.Connection;
import com.rabbitmq.client.Channel;

ConnectionFactory factory = new ConnectionFactory();
factory.setHost("localhost");
factory.setPort(5673);
factory.setUsername("admin");
factory.setPassword("admin123");
factory.setVirtualHost("/");

Connection connection = factory.newConnection();
Channel channel = connection.createChannel();

// Declare queue
channel.queueDeclare("hello", true, false, false, null);

// Send message
String message = "Hello World!";
channel.basicPublish("", "hello", 
    MessageProperties.PERSISTENT_TEXT_PLAIN, 
    message.getBytes("UTF-8"));

connection.close();
```

### Spring Boot (application.yml)
```yaml
spring:
  rabbitmq:
    host: localhost
    port: 5673
    username: admin
    password: admin123
    virtual-host: /
    connection-timeout: 15000
    publisher-confirm-type: correlated
    publisher-returns: true
```

## Monitoring và Management

### CLI Commands
```bash
# Check status
docker exec rabbitmq rabbitmqctl status

# List queues
docker exec rabbitmq rabbitmqctl list_queues

# List exchanges
docker exec rabbitmq rabbitmqctl list_exchanges

# List users
docker exec rabbitmq rabbitmqctl list_users

# Add user
docker exec rabbitmq rabbitmqctl add_user newuser password

# Set permissions
docker exec rabbitmq rabbitmqctl set_permissions -p / newuser ".*" ".*" ".*"
```

### Management API
```bash
# Get overview
curl -u admin:admin123 http://localhost:15673/api/overview

# List queues
curl -u admin:admin123 http://localhost:15673/api/queues

# Get queue info
curl -u admin:admin123 http://localhost:15673/api/queues/%2F/sample.queue
```

## Troubleshooting

### Container không start
1. Kiểm tra logs: `docker compose logs rabbitmq`
2. Kiểm tra port conflicts: `netstat -tulpn | grep :5673`

### Không connect được
1. Kiểm tra container status: `docker compose ps`
2. Kiểm tra network: `docker network ls`
3. Test connection: `telnet localhost 5673`

### Performance tuning
- Tăng memory limit trong `rabbitmq.conf`: `vm_memory_high_watermark.relative = 0.6`
- Adjust disk space: `disk_free_limit.relative = 2.0`
