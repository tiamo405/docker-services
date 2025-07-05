#!/bin/bash

# Redpanda Setup Script for SASL Authentication

echo "Setting up Redpanda with SASL authentication..."

# Wait for Redpanda to be ready
echo "Waiting for Redpanda to start..."
sleep 10

# Create SASL user
echo "Creating SASL user 'admin'..."
docker exec redpanda rpk acl user create admin --password admin2k25 --mechanism SCRAM-SHA-256

# Create topic
echo "Creating topic 'gsht_topic_local_namtp'..."
docker exec redpanda rpk topic create gsht_topic_local_namtp --partitions 3 --replicas 1

# Grant permissions to admin user
echo "Granting permissions to admin user..."
docker exec redpanda rpk acl create --allow-principal User:admin --operation all --topic gsht_topic_local_namtp
docker exec redpanda rpk acl create --allow-principal User:admin --operation all --group gsht_group_local

# List topics to verify
echo "Listing topics..."
docker exec redpanda rpk topic list

echo "Setup completed!"
echo "Redpanda Console: http://localhost:8080"
echo "Kafka Bootstrap Server: localhost:9223"
echo "Admin User: admin / admin2k25"
