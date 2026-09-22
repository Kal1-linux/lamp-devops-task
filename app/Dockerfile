# ---------------------------------------------------------------------------
# Stage 1: Build & Dependency Preparation Stage
# ---------------------------------------------------------------------------
FROM alpine:3.19 AS builder

WORKDIR /app
COPY index.php /app/index.php

# ---------------------------------------------------------------------------
# Stage 2: Final Secure Production Runtime Stage (Least-Privilege Non-Root)
# ---------------------------------------------------------------------------
FROM alpine:3.19 AS runner

# Install runtime dependencies with no cache
RUN apk add --no-cache \
    nginx \
    php83 \
    php83-fpm \
    php83-mysqli \
    php83-session \
    php83-json \
    php83-mbstring \
    supervisor \
    && ln -sf /usr/bin/php83 /usr/bin/php

# Create required runtime directories and set ownership for unprivileged execution
RUN mkdir -p /run/nginx /var/www/html /var/log/supervisor /var/log/nginx /var/log/php83 \
    && chown -R nginx:nginx /run/nginx /var/www/html /var/log/supervisor /var/log/nginx /var/log/php83 /var/lib/nginx

# Copy application assets from builder stage
COPY --chown=nginx:nginx --from=builder /app/index.php /var/www/html/index.php

# Copy server & process configurations
COPY --chown=nginx:nginx default.conf /etc/nginx/http.d/default.conf
COPY --chown=nginx:nginx www.conf /etc/php83/php-fpm.d/www.conf
COPY --chown=nginx:nginx supervisord.conf /etc/supervisord.conf

# Expose HTTP port 80
EXPOSE 80

# Execute container under non-root nginx user context
USER nginx

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
