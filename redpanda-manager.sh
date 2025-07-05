#!/bin/bash

# Redpanda Management Script

REDPANDA_CONTAINER="redpanda"

case "$1" in
    "start")
        echo "Starting Redpanda services..."
        cd services/redpanda && docker-compose up -d
        echo "Waiting for Redpanda to be ready..."
        sleep 15
        echo "Redpanda started successfully!"
        echo "Console UI: http://localhost:8080"
        echo "Kafka Bootstrap: localhost:9223"
        ;;
    "stop")
        echo "Stopping Redpanda services..."
        cd services/redpanda && docker-compose down
        echo "Redpanda stopped successfully!"
        ;;
    "restart")
        echo "Restarting Redpanda services..."
        cd services/redpanda && docker-compose restart
        echo "Redpanda restarted successfully!"
        ;;
    "setup")
        echo "Setting up SASL authentication..."
        chmod +x services/redpanda/setup-sasl.sh
        ./services/redpanda/setup-sasl.sh
        ;;
    "topic-list")
        echo "Listing topics..."
        docker exec $REDPANDA_CONTAINER rpk topic list
        ;;
    "topic-create")
        if [ -z "$2" ]; then
            echo "Usage: $0 topic-create <topic-name>"
            exit 1
        fi
        echo "Creating topic: $2"
        docker exec $REDPANDA_CONTAINER rpk topic create $2 --partitions 3 --replicas 1
        ;;
    "consumer-groups")
        echo "Listing consumer groups..."
        docker exec $REDPANDA_CONTAINER rpk group list
        ;;
    "cluster-info")
        echo "Cluster information:"
        docker exec $REDPANDA_CONTAINER rpk cluster info
        ;;
    "logs")
        echo "Redpanda logs:"
        docker logs $REDPANDA_CONTAINER --tail 50 -f
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|setup|topic-list|topic-create|consumer-groups|cluster-info|logs}"
        echo ""
        echo "Commands:"
        echo "  start         - Start Redpanda services"
        echo "  stop          - Stop Redpanda services"
        echo "  restart       - Restart Redpanda services"
        echo "  setup         - Setup SASL authentication"
        echo "  topic-list    - List all topics"
        echo "  topic-create  - Create a new topic"
        echo "  consumer-groups - List consumer groups"
        echo "  cluster-info  - Show cluster information"
        echo "  logs          - Show Redpanda logs"
        exit 1
        ;;
esac
