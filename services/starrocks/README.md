# StarRocks Database Setup

StarRocks là một OLAP database engine hiệu suất cao, được thiết kế cho phân tích dữ liệu thời gian thực.

## Lưu trữ dữ liệu

### Thư mục data được mount:
- **FE Meta**: `../../data/starrocks/fe/` → `/data/deploy/starrocks/fe/meta`
- **BE Storage**: `../../data/starrocks/be/` → `/data/deploy/starrocks/be/storage`

Tất cả dữ liệu database được lưu persistent trong thư mục `data/starrocks/` trên host machine. Khi restart container, dữ liệu sẽ được giữ nguyên.

### Thông tin kết nối
- **Host**: 127.0.0.1 (hoặc localhost)
- **Port**: 9030 (MySQL protocol)
- **Username**: root
- **Password**: (không có password)
- **Protocol**: TCP

### Ports được expose
- `9030`: MySQL protocol port (kết nối từ application)
- `8030`: HTTP port cho Frontend (Web UI)
- `8040`: HTTP port cho Backend
- `9020`: RPC port cho Frontend
- `9050`: Heartbeat service port cho Backend
- `8060`: Brpc port cho Backend

## Cách sử dụng

### Khởi động StarRocks
```bash
cd /home/namtp/docker-services/services/starrocks
docker compose up -d
```

### Khởi tạo database (chạy sau khi container đã start)
```bash
# Đợi khoảng 2-3 phút để StarRocks khởi động hoàn toàn, sau đó chạy:
./init-db.sh
```

### Kiểm tra logs
```bash
docker compose logs -f starrocks
```

### Kết nối vào database
```bash
# Sử dụng MySQL client
mysql -h 127.0.0.1 -P 9030 -u root --protocol=TCP

# Hoặc sử dụng Docker exec
docker exec -it starrocks mysql -h 127.0.0.1 -P 9030 -u root --protocol=TCP
```

### Truy cập Web UI
<!-- Mở trình duyệt và truy cập: http://localhost:8080 -->

### Dừng service
```bash
docker compose down
```

## Cấu hình file

### fe.conf
Cấu hình cho Frontend (FE) - query engine
- `query_port`: Port cho MySQL protocol
- `http_port`: Port cho Web UI
- `meta_dir`: Thư mục metadata

### be.conf
Cấu hình cho Backend (BE) - storage engine
- `be_http_port`: Port HTTP cho BE
- `heartbeat_service_port`: Port heartbeat
- `storage_root_path`: Thư mục lưu trữ data

### init.sql
Script khởi tạo database và sample data:
- Tạo user root với password 'root'
- Tạo database sample_db
- Tạo bảng users với sample data

## Kết nối từ code

### Python (sử dụng PyMySQL)
```python
import pymysql

connection = pymysql.connect(
    host='127.0.0.1',
    port=9030,
    user='root',
    database='sample_db'
)

cursor = connection.cursor()
cursor.execute("SELECT * FROM users")
results = cursor.fetchall()
print(results)
```

### Node.js (sử dụng mysql2)
```javascript
const mysql = require('mysql2');

const connection = mysql.createConnection({
    host: '127.0.0.1',
    port: 9030,
    user: 'root',
    database: 'sample_db'
});

connection.query('SELECT * FROM users', (error, results) => {
    if (error) throw error;
    console.log(results);
});
```

### Java (sử dụng JDBC)
```java
String url = "jdbc:mysql://127.0.0.1:9030/sample_db";
String username = "root";
String password = "";

Connection connection = DriverManager.getConnection(url, username, password);
Statement statement = connection.createStatement();
ResultSet resultSet = statement.executeQuery("SELECT * FROM users");
```

## Troubleshooting

### Container không start
1. Kiểm tra logs: `docker-compose logs starrocks`
2. Kiểm tra port conflicts: `netstat -tulpn | grep :9030`

### Không kết nối được
1. Kiểm tra container status: `docker-compose ps`
2. Kiểm tra healthcheck: `docker inspect starrocks`
3. Đợi container khởi động hoàn toàn (có thể mất 2-3 phút)

### Performance tuning
- Tăng memory limit trong `fe.conf`: `JAVA_OPTS = "-Xmx8192m"`
- Tăng memory limit trong `be.conf`: `mem_limit = 80%`
