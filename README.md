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

All services are configured to store data in `~/docker/data/` directory:
- MySQL data: `~/docker/data/mysql`
- MongoDB data: `~/docker/data/mongodb`
- PostgreSQL data: `~/docker/data/postgres`
- Redis data: `~/docker/data/redis`
- MinIO data: `~/docker/data/minio`

## Usage

### Start all services
```bash
docker-compose up -d
```

### Start individual services
```bash
cd services/mysql && docker-compose up -d
cd services/mongodb && docker-compose up -d
cd services/postgres && docker-compose up -d
cd services/redis && docker-compose up -d
cd services/minio && docker-compose up -d
```

### Stop all services
```bash
docker-compose down
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
- Persistence enabled

### MinIO
- Web UI: http://localhost:9001
- API: http://localhost:9000
- Admin: admin / minioadmin

## Configuration

Each service has its own configuration directory under `services/<service>/config/`. Modify these files to customize service behavior.