#!/bin/bash

# Script to initialize StarRocks database after container is running
echo "Initializing StarRocks database..."

# Wait for StarRocks to be ready
echo "Waiting for StarRocks to be ready..."
until mysql -h 127.0.0.1 -P 9030 -u root --protocol=TCP -e "SELECT 1" &> /dev/null; do
    echo "StarRocks is not ready yet, waiting..."
    sleep 5
done

echo "StarRocks is ready! Running initialization script..."

# Run the initialization SQL
mysql -h 127.0.0.1 -P 9030 -u root --protocol=TCP < ~/docker-services/services/starrocks/config/init.sql

echo "StarRocks initialization completed!"
echo "You can now connect to StarRocks using:"
echo "mysql -h 127.0.0.1 -P 9030 -u root --protocol=TCP"
