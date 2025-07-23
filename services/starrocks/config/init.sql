-- Initialize StarRocks database
-- Create a sample database for testing
CREATE DATABASE IF NOT EXISTS sample_db;

-- Use the sample database
USE sample_db;

-- Create a sample table for testing
CREATE TABLE IF NOT EXISTS users (
    id BIGINT,
    name VARCHAR(100),
    email VARCHAR(100),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP()
) ENGINE=OLAP
DUPLICATE KEY(id)
DISTRIBUTED BY HASH(id) BUCKETS 10
PROPERTIES (
    "replication_num" = "1"
);

-- Insert sample data
INSERT INTO users (id, name, email) VALUES 
(1, 'John Doe', 'john@example.com'),
(2, 'Jane Smith', 'jane@example.com'),
(3, 'Bob Johnson', 'bob@example.com');
