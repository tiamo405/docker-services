#!/bin/bash

# Redis Management Script

REDIS_CONTAINER="redis"
REDIS_CLI="docker exec -it $REDIS_CONTAINER redis-cli -a Gsht.2k24!@#"

case "$1" in
    "start")
        echo "Starting Redis service..."
        cd services/redis && docker-compose up -d
        echo "Redis started successfully!"
        echo "Connection: redis://localhost:6379"
        echo "Password: Gsht.2k24!@#"
        ;;
    "stop")
        echo "Stopping Redis service..."
        cd services/redis && docker-compose down
        echo "Redis stopped successfully!"
        ;;
    "restart")
        echo "Restarting Redis service..."
        cd services/redis && docker-compose restart
        echo "Redis restarted successfully!"
        ;;
    "cli")
        echo "Connecting to Redis CLI..."
        $REDIS_CLI
        ;;
    "info")
        echo "Redis Information:"
        $REDIS_CLI INFO server
        ;;
    "monitor")
        echo "Monitoring Redis commands..."
        $REDIS_CLI MONITOR
        ;;
    "test")
        echo "Testing Redis connection..."
        $REDIS_CLI PING
        if [ $? -eq 0 ]; then
            echo "✓ Redis connection successful!"
        else
            echo "✗ Redis connection failed!"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|cli|info|monitor|test}"
        echo ""
        echo "Commands:"
        echo "  start    - Start Redis service"
        echo "  stop     - Stop Redis service" 
        echo "  restart  - Restart Redis service"
        echo "  cli      - Connect to Redis CLI"
        echo "  info     - Show Redis server info"
        echo "  monitor  - Monitor Redis commands"
        echo "  test     - Test Redis connection"
        exit 1
        ;;
esac
