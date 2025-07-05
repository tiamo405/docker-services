#!/bin/bash

# Redpanda SASL Setup Script
# This script configures SASL authentication for external access

echo "=== Redpanda SASL Setup ==="
echo

# Wait for Redpanda to be ready
echo "1. Waiting for Redpanda to be ready..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if docker exec redpanda-sasl rpk cluster info --brokers localhost:9092 >/dev/null 2>&1; then
        echo "✅ Redpanda is ready"
        break
    fi
    
    echo "   Waiting... (attempt $((attempt + 1))/$max_attempts)"
    sleep 2
    attempt=$((attempt + 1))
done

if [ $attempt -eq $max_attempts ]; then
    echo "❌ Redpanda failed to start within timeout"
    exit 1
fi

# Create admin user first (while SASL is disabled)
echo
echo "2. Creating admin user..."
if docker exec redpanda-sasl rpk acl user list --brokers localhost:9092 2>/dev/null | grep -q admin; then
    echo "✅ Admin user already exists"
else
    docker exec redpanda-sasl rpk acl user create admin --password admin2k25 --mechanism SCRAM-SHA-256 --brokers localhost:9092
    echo "✅ Admin user created"
fi

# Set superuser privileges
echo
echo "3. Setting superuser privileges..."
docker exec redpanda-sasl rpk cluster config set superusers '[admin]'
echo "✅ Admin user granted superuser privileges"

# Enable SASL globally
echo
echo "4. Enabling SASL authentication..."
docker exec redpanda-sasl rpk cluster config set enable_sasl true
echo "✅ SASL enabled globally"

# Create application topic using SASL authentication
echo
echo "5. Creating application topic..."
if docker exec redpanda-sasl rpk topic list --brokers localhost:9092 --user admin --password admin2k25 --sasl-mechanism SCRAM-SHA-256 2>/dev/null | grep -q gsht_topic_local_namtp; then
    echo "✅ Topic 'gsht_topic_local_namtp' already exists"
else
    docker exec redpanda-sasl rpk topic create gsht_topic_local_namtp --partitions 3 --replicas 1 --brokers localhost:9092 --user admin --password admin2k25 --sasl-mechanism SCRAM-SHA-256
    echo "✅ Topic 'gsht_topic_local_namtp' created"
fi

# Verify SASL authentication works
echo
echo "6. Verifying SASL authentication..."
if docker exec redpanda-sasl rpk topic list --brokers localhost:9092 --user admin --password admin2k25 --sasl-mechanism SCRAM-SHA-256 >/dev/null 2>&1; then
    echo "✅ SASL authentication is working"
else
    echo "❌ SASL authentication failed"
    exit 1
fi

# Verify unauthenticated access is blocked
echo
echo "7. Verifying unauthenticated access is blocked..."
if docker exec redpanda-sasl rpk topic list --brokers localhost:9092 2>/dev/null; then
    echo "❌ Unauthenticated access incorrectly allowed"
    exit 1
else
    echo "✅ Unauthenticated access correctly blocked"
fi

echo
echo "=== Setup Complete ==="
echo "Redpanda is ready with SASL authentication!"
echo
echo "Connection details:"
echo "  Port: localhost:9092 (SASL required)"
echo "  External port: localhost:9223 (SASL required)"
echo "  Username: admin"
echo "  Password: admin2k25"
echo "  Mechanism: SCRAM-SHA-256"
echo "  Topic: gsht_topic_local_namtp"
echo
echo "⚠️  Note: This version of Redpanda does not support per-listener"
echo "   authentication. SASL is enabled globally on all ports."
echo
echo "Web Console: http://localhost:8080 (may need SASL configuration)"
echo "Config example: redpanda-config-example.json"
