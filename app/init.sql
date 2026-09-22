-- Runs automatically on first MySQL container startup via
-- /docker-entrypoint-initdb.d/init.sql
CREATE DATABASE IF NOT EXISTS appdb;

CREATE TABLE IF NOT EXISTS appdb.messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO appdb.messages (message) VALUES ('Hello, World! Seed row from init.sql');
