<?php
// Database connection settings come from environment variables so the same
// image works unchanged in Docker Compose, Kubernetes, or a VM.
$dbHost = getenv('DB_HOST') ?: 'mysql';
$dbPort = getenv('DB_PORT') ?: '3306';
$dbUser = getenv('DB_USER') ?: 'appuser';
$dbPass = getenv('DB_PASSWORD') ?: 'apppassword';
$dbName = getenv('DB_NAME') ?: 'appdb';

$mysqli = @new mysqli($dbHost, $dbUser, $dbPass, $dbName, (int)$dbPort);

header('Content-Type: text/html; charset=utf-8');

echo "<!DOCTYPE html><html><head><title>LAMP Stack Demo</title></head><body>";
echo "<h1>LAMP Stack Deployment</h1>";

if ($mysqli->connect_errno) {
    echo "<p style='color:red;'>Could not connect to MySQL: " . htmlspecialchars($mysqli->connect_error) . "</p>";
} else {
    echo "<p>Hello, World! Your MySQL connection is successful.</p>";
    echo "<p>Connected to database <strong>" . htmlspecialchars($dbName) . "</strong> on host <strong>" . htmlspecialchars($dbHost) . "</strong>.</p>";

    $result = $mysqli->query("SELECT NOW() AS server_time, VERSION() AS mysql_version");
    if ($result && $row = $result->fetch_assoc()) {
        echo "<p>MySQL server time: " . htmlspecialchars($row['server_time']) . "</p>";
        echo "<p>MySQL version: " . htmlspecialchars($row['mysql_version']) . "</p>";
    }
    $mysqli->close();
}

echo "</body></html>";
