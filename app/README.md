# Application Layer — LAMP Stack in Docker

Nginx + PHP-FPM (Alpine, multi-stage, non-root image) serving a PHP page
that connects to a separate MySQL container.

## Files
- `Dockerfile` — multi-stage non-root build for Nginx + PHP-FPM
- `default.conf` — Nginx server block routing `.php` requests to PHP-FPM
- `www.conf` — PHP-FPM pool listening on `127.0.0.1:9000`
- `supervisord.conf` — process manager running Nginx and PHP-FPM as non-daemon processes
- `index.php` — PHP application script connecting to MySQL via environment variables
- `init.sql` — database schema initialization script
- `docker-compose.yml` — orchestration for application and MySQL containers
- `.env.example` — environment variables template

## Option A: Docker Compose (recommended)

```bash
cd app
docker compose up --build -d
```

Visit `http://localhost` — you will see:
> Hello, World! Your MySQL connection is successful.

Stop and clean up:
```bash
docker compose down -v
```

## Option B: Plain `docker run` (two separate containers)

```bash
# 1. Create a network so containers resolve each other by name
docker network create lamp-net

# 2. Start MySQL
docker run -d --name mysql --network lamp-net \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=appdb \
  -e MYSQL_USER=appuser \
  -e MYSQL_PASSWORD=apppassword \
  -v $(pwd)/init.sql:/docker-entrypoint-initdb.d/init.sql:ro \
  mysql:8.0

# 3. Build and run the web container
docker build -t lamp-web .
docker run -d --name web --network lamp-net -p 80:80 \
  -e DB_HOST=mysql -e DB_PORT=3306 -e DB_USER=appuser \
  -e DB_PASSWORD=apppassword -e DB_NAME=appdb \
  lamp-web
```

## Design Notes
- Alpine base keeps the image minimal (~40 MB).
- Multi-stage build executes under non-root user `USER nginx` for security.
- All database connection details are environment-driven via `getenv()` so the image works unchanged across Compose, Kubernetes, or VMs.
