# Docker Services

A complete Docker services setup with MySQL, MongoDB, PostgreSQL, Redis, and MinIO.

## Project Structure

```
docker-services/
├── docker-compose.yml          # Main orchestration file
├── services/                   # Individual service configurations
│   ├── mysql/
│   │   ├── docker-compose.yml
│   │   └── config/
│   │       └── my.cnf
│   ├── mongodb/
│   │   ├── docker-compose.yml
│   │   └── config/
│   ├── postgres/
│   │   ├── docker-compose.yml
│   │   └── config/
│   ├── redis/
│   │   ├── docker-compose.yml
│   │   └── config/
│   │       └── redis.conf
│   └── minio/
│       ├── docker-compose.yml
│       └── config/
└── data/                       # Persistent data storage
    ├── mysql/
    ├── mongodb/
    ├── postgres/
    ├── redis/
    └── minio/
```

## Data Persistence

All services are configured to store data in `~/docker-services/data/` directory:
- MySQL data: `~/docker-services/data/mysql`
- MongoDB data: `~/docker-services/data/mongodb`
- PostgreSQL data: `~/docker-services/data/postgres`
- Redis data: `~/docker-services/data/redis`
- MinIO data: `~/minio/data` (separate location for MinIO)

## Usage

###
```bash
cd ~/
git clone https://github.com/tiamo405/docker-services.git
cd ~/docker-services/
mkdir data
mkdir data/{mysql,mongodb,redis,postgres,minio}
chmod +x install-docker.sh
./install-docker.sh

```
### Start all services
```bash
docker compose up -d
```

### Start individual services
```bash
cd services/mysql && docker compose up -d
cd services/mongodb && docker compose up -d
cd services/postgres && docker compose up -d
cd services/redis && docker compose up -d
cd services/minio && docker compose up -d
```

### Stop all services
```bash
docker compose down
```

## Service Details

### MySQL
- Port: 3306
- Root password: rootpassword
- Database: myapp
- User: user / password

### MongoDB
- Port: 27017
- Admin user: user / password
- Database: myapp

### PostgreSQL
- Port: 5432
- Database: myapp
- User: user / password

### Redis
- Port: 6379
- Password: Gsht.2k24!@#
- Connection: redis://localhost:6379
- Persistence enabled with AOF
- Optimized for local development

### Redpanda
- Kafka API Port: 9223 (external), 9092 (internal)
- Console UI: http://localhost:8080
- Schema Registry: http://localhost:8084
- Admin API: http://localhost:9644
- SASL Authentication: SCRAM-SHA-256
- Admin User: admin / admin2k25
- Topic: gsht_topic_local_namtp
- Consumer Group: gsht_group_local

### MinIO
- Web UI: http://localhost:9001
- API: http://localhost:9000
- Admin: admin / minioadmin

## Configuration

Each service has its own configuration directory under `services/<service>/config/`. Modify these files to customize service behavior.

## Quick Testing

### Test All Services
```bash
# Test Redpanda SASL authentication
./test-redpanda-sasl.sh

# Check all service status
docker compose ps
```