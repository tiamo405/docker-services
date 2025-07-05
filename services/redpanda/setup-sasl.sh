#!/bin/bash

# Redpanda Setup Script for SASL Authentication

echo "Setting up Redpanda with SASL authentication..."

# Wait for Redpanda to be ready
echo "Waiting for Redpanda to start..."
sleep 15

# Create SASL user
echo "Creating SASL user 'admin'..."
docker exec redpanda-sasl rpk acl user create admin --password admin2k25 --api-urls localhost:9644

# Create topic with SASL authentication
echo "Creating topic 'gsht_topic_local_namtp'..."
docker exec redpanda-sasl rpk topic create gsht_topic_local_namtp --partitions 3 --replicas 1 --brokers localhost:9092 --user admin --password admin2k25 --sasl-mechanism SCRAM-SHA-256

# Grant permissions to admin user
echo "Granting permissions to admin user..."
docker exec redpanda-sasl rpk acl create --allow-principal User:admin --operation all --topic gsht_topic_local_namtp --brokers localhost:9092 --user admin --password admin2k25 --sasl-mechanism SCRAM-SHA-256
docker exec redpanda-sasl rpk acl create --allow-principal User:admin --operation all --group gsht_group_local --brokers localhost:9092 --user admin --password admin2k25 --sasl-mechanism SCRAM-SHA-256

# List topics to verify
echo "Listing topics..."
docker exec redpanda-sasl rpk topic list --brokers localhost:9092 --user admin --password admin2k25 --sasl-mechanism SCRAM-SHA-256

echo "Setup completed!"
echo "Redpanda Console: http://localhost:8080"
echo "Kafka Bootstrap Server internal: localhost:9223 (port 9092)"
echo "Kafka Bootstrap Server external: localhost:9123 (port 9093)"
echo "Admin User: admin / admin2k25"
