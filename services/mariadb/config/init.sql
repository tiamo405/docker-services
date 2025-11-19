-- MariaDB initialization script
-- This script will be executed automatically when the container starts for the first time

-- Create additional databases if needed
-- CREATE DATABASE IF NOT EXISTS `test_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant additional privileges if needed
GRANT ALL PRIVILEGES ON `quanlyluhanhdb`.* TO 'quanlyluhanhdb'@'%';

-- Create additional users if needed
-- CREATE USER IF NOT EXISTS 'readonly'@'%' IDENTIFIED BY 'readonly123';
-- GRANT SELECT ON `quanlyluhanhdb`.* TO 'readonly'@'%';

-- Flush privileges to ensure changes take effect
FLUSH PRIVILEGES;

-- Create sample table for testing (optional)
USE `quanlyluhanhdb`;

CREATE TABLE IF NOT EXISTS `users` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `username` varchar(50) NOT NULL,
    `email` varchar(100) NOT NULL,
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `username` (`username`),
    UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert sample data
INSERT INTO `users` (`username`, `email`) VALUES 
('admin', 'admin@example.com'),
('testuser', 'test@example.com')
ON DUPLICATE KEY UPDATE username=VALUES(username);