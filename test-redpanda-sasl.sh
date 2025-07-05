#!/bin/bash

# Redpanda SASL Connection Test Script
echo "=== Redpanda SASL Authentication Test ==="
echo

# Check if container is running
echo "1. Checking Redpanda container status..."
if ! docker ps | grep -q redpanda; then
    echo "❌ Redpanda container is not running!"
    echo "   Start with: cd services/redpanda && docker compose up -d"
    exit 1
fi
echo "✅ Redpanda container is running"

# Check SASL configuration
echo
echo "2. Checking SASL configuration..."
SASL_ENABLED=$(docker exec redpanda rpk cluster config get enable_sasl 2>/dev/null)
if [ "$SASL_ENABLED" = "true" ]; then
    echo "✅ SASL authentication is enabled"
else
    echo "❌ SASL authentication is not enabled"
    echo "   Fix with: docker exec redpanda rpk cluster config set enable_sasl true"
    exit 1
fi

# Check if admin user exists
echo
echo "3. Checking admin user..."
if docker exec redpanda rpk acl user list 2>/dev/null | grep -q admin; then
    echo "✅ Admin user exists"
else
    echo "❌ Admin user does not exist"
    echo "   Create with: docker exec redpanda rpk acl user create admin --password admin2k25 --mechanism SCRAM-SHA-256"
    exit 1
fi

# Test connection without auth (should fail)
echo
echo "4. Testing connection without authentication (should fail)..."
if docker exec redpanda rpk topic list --brokers localhost:9223 2>/dev/null >/dev/null; then
    echo "⚠️  Connection without auth succeeded (SASL may not be working on port 9223)"
else
    echo "✅ Connection without auth failed as expected"
fi

# Test connection with SASL
echo
echo "5. Testing SASL authentication..."
if docker exec redpanda rpk topic list --brokers localhost:9223 --user admin --password admin2k25 --sasl-mechanism SCRAM-SHA-256 >/dev/null 2>&1; then
    echo "✅ SASL authentication successful!"
else
    echo "❌ SASL authentication failed"
    echo "   Make sure admin user has superuser privileges:"
    echo "   docker exec redpanda rpk cluster config set superusers '[admin]'"
    exit 1
fi

# Show available topics
echo
echo "6. Listing available topics..."
docker exec redpanda rpk topic list --brokers localhost:9223 --user admin --password admin2k25 --sasl-mechanism SCRAM-SHA-256

echo
echo "=== Test Results ==="
echo "✅ Redpanda SASL authentication is working correctly!"
echo
echo "Connection details:"
echo "  External port: localhost:9223 (SASL required)"
echo "  Internal port: localhost:9092 (no auth - for services)"
echo "  Username: admin"
echo "  Password: admin2k25"
echo "  Mechanism: SCRAM-SHA-256"
echo
echo "Web Console: http://localhost:8080"
echo
echo "Example client config is available in: redpanda-config-example.json"
