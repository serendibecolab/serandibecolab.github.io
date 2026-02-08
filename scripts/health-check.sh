#!/bin/bash

# Health check script for Astro Static Site served by Nginx
set -e

MAX_RETRIES=10
RETRY_INTERVAL=5 # Increased retry interval for Nginx reload
LOG_FILE="/home/banumath/Projects/yukina/health-check.log"
WEB_SERVER_SERVICE="nginx" # Your web server service name
SITE_URL="http://localhost/" # The URL to check (Nginx default port)

log() {
    echo "$(date): $1" >> $LOG_FILE
}

# Check Nginx service status
check_nginx_status() {
    sudo systemctl is-active --quiet $WEB_SERVER_SERVICE
    return $?
}

log "Starting health check for static site..."

# Check Nginx service first
if ! check_nginx_status; then
    log "❌ $WEB_SERVER_SERVICE service is not running."
    echo "❌ $WEB_SERVER_SERVICE service is not running."
    exit 1
fi
log "✅ $WEB_SERVER_SERVICE service is active."

# Check site accessibility
for i in $(seq 1 $MAX_RETRIES); do
    RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" $SITE_URL 2>/dev/null || echo "000")
    
    case $RESPONSE_CODE in
        200|304)
            log "✅ Site is accessible (HTTP $RESPONSE_CODE) at $SITE_URL"
            echo "✅ Site is accessible (HTTP $RESPONSE_CODE)"
            exit 0
            ;;
        000)
            log "🔌 Site is not responding at $SITE_URL (attempt $i/$MAX_RETRIES)"
            echo "🔌 Site is not responding (attempt $i/$MAX_RETRIES)"
            ;;
        5*)
            log "💥 Site returned server error (HTTP $RESPONSE_CODE) at $SITE_URL (attempt $i/$MAX_RETRIES)"
            echo "💥 Site returned server error (HTTP $RESPONSE_CODE) (attempt $i/$MAX_RETRIES)"
            ;;
        4*)
            log "⚠️  Site returned client error (HTTP $RESPONSE_CODE) at $SITE_URL (attempt $i/$MAX_RETRIES)"
            echo "⚠️  Site returned client error (HTTP $RESPONSE_CODE) (attempt $i/$MAX_RETRIES)"
            # For static sites, a 4xx might mean a missing page, but the server is still "healthy"
            exit 0
            ;;
        *)
            log "❓ Site returned unexpected code: $RESPONSE_CODE at $SITE_URL (attempt $i/$MAX_RETRIES)"
            echo "❓ Site returned unexpected response (HTTP $RESPONSE_CODE) (attempt $i/$MAX_RETRIES)"
            ;;
    esac
    
    sleep $RETRY_INTERVAL
done

log "❌ Site failed health check after $MAX_RETRIES attempts at $SITE_URL"
echo "❌ Site failed health check"
exit 1
