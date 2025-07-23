#!/bin/bash

# StarRocks startup script
echo "Starting StarRocks..."

# Find StarRocks installation directory
STARROCKS_HOME=$(find /opt -name "StarRocks-*" -type d 2>/dev/null | head -1)
if [ -z "$STARROCKS_HOME" ]; then
    STARROCKS_HOME="/opt/starrocks"
fi

echo "StarRocks home: $STARROCKS_HOME"

# Start Frontend (FE)
echo "Starting Frontend..."
cd $STARROCKS_HOME/fe
./bin/start_fe.sh --daemon

# Wait for FE to start
echo "Waiting for Frontend to start..."
sleep 30

# Check if FE is running
FE_PID=$(ps aux | grep "StarRocksFE" | grep -v grep | awk '{print $2}')
if [ -z "$FE_PID" ]; then
    echo "Failed to start Frontend"
    exit 1
fi

echo "Frontend started with PID: $FE_PID"

# Start Backend (BE)
echo "Starting Backend..."
cd $STARROCKS_HOME/be
./bin/start_be.sh --daemon

# Wait for BE to start
echo "Waiting for Backend to start..."
sleep 30

# Check if BE is running
BE_PID=$(ps aux | grep "starrocks_be" | grep -v grep | awk '{print $2}')
if [ -z "$BE_PID" ]; then
    echo "Failed to start Backend"
    exit 1
fi

echo "Backend started with PID: $BE_PID"

# Add BE to cluster
echo "Adding Backend to cluster..."
sleep 10
mysql -h 127.0.0.1 -P 9030 -u root -proot -e "ALTER SYSTEM ADD BACKEND '127.0.0.1:9050';" 2>/dev/null || echo "Backend already added or error occurred"

# Run initialization SQL
echo "Running initialization SQL..."
sleep 5
mysql -h 127.0.0.1 -P 9030 -u root -proot < /opt/starrocks/init.sql 2>/dev/null || echo "Init SQL executed or error occurred"

echo "StarRocks started successfully!"
echo "Frontend: http://localhost:8030"
echo "MySQL connection: mysql -h localhost -P 9030 -u root -proot"

# Keep container running
tail -f $STARROCKS_HOME/fe/log/fe.log
