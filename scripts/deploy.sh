#!/bin/bash

# Auto-deploy script for Astro Static Site Generation (SSG) with zero-downtime via symlinks
set -e

echo "🚀 Starting zero-downtime deployment process..."

# Configuration
BRANCH="${1:-Dev}" # Default to 'Dev' if no argument is provided
PROJECT_DIR="$(dirname "$(readlink -f "$0")")/.." # Project root is parent of script directory
DEPLOY_BASE_DIR="$PROJECT_DIR/deploy" # Base directory for all deployments
CURRENT_SYMLINK="$DEPLOY_BASE_DIR/current" # Symlink to the active release
LOG_FILE="$PROJECT_DIR/deploy.log"
WEB_SERVER_SERVICE="nginx" # Your web server service name

# Create base deployment directory if it doesn't exist
mkdir -p $DEPLOY_BASE_DIR

# Log function
log() {
    echo "$(date): $1" >> $LOG_FILE
    echo "$1"
}

# Error handling
handle_error() {
    local error_msg=$1
    log "❌ DEPLOYMENT FAILED: $error_msg"
    log "⚠️  Please check the logs for details and manually intervene if necessary."
    exit 1
}

# Main deployment function
deploy() {
    log "📦 Starting static site deployment process..."
    
    # Step 1: Pull latest changes
    cd $PROJECT_DIR || handle_error "Failed to change to project directory"
    log "🔄 Pulling latest changes from $BRANCH..."
    git fetch origin || handle_error "Git fetch failed"
    git reset --hard origin/$BRANCH || handle_error "Git reset failed"

    # Step 2: Install dependencies
    log "📦 Installing dependencies..."
    pnpm install || handle_error "pnpm install failed"

    # Step 3: Create a new timestamped release directory
    local TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    local NEW_RELEASE_DIR="$DEPLOY_BASE_DIR/build_$TIMESTAMP"
    mkdir -p $NEW_RELEASE_DIR || handle_error "Failed to create new release directory: $NEW_RELEASE_DIR"
    log "📋 Created new release directory: $NEW_RELEASE_DIR"

    # Step 4: Build the project into the new release directory
    log "🏗️ Building Astro static site into $NEW_RELEASE_DIR..."
    # Temporarily change ASTRO_OUT_DIR to build directly into the new release directory
    ASTRO_OUT_DIR="$NEW_RELEASE_DIR" pnpm run build || handle_error "Build failed"

    # Step 5: Atomically update the 'current' symlink
    log "🔄 Atomically updating '$CURRENT_SYMLINK' to point to '$NEW_RELEASE_DIR'..."
    ln -sfn "$NEW_RELEASE_DIR" "$CURRENT_SYMLINK" || handle_error "Failed to update current symlink"

    # Step 6: Reload the web server (if necessary, depending on Nginx config)
    # This step might be optional if Nginx is configured to follow symlinks and
    # doesn't cache aggressively. However, a reload ensures Nginx picks up the change.
    log "🌐 Reloading $WEB_SERVER_SERVICE to serve new content (via symlink)..."
    sudo systemctl reload $WEB_SERVER_SERVICE || handle_error "Failed to reload $WEB_SERVER_SERVICE. Check its status."

    log "✅ Deployment completed successfully! New release: $(basename $NEW_RELEASE_DIR)"
    echo "🌐 Site should now be live with the latest changes."
    echo "💡 IMPORTANT: Ensure your Nginx configuration 'root' directive points to: $CURRENT_SYMLINK"
}

# Run deployment
deploy

# Cleanup old releases (keep last 5)
log "🧹 Cleaning up old releases..."
ls -dt $DEPLOY_BASE_DIR/build_* | tail -n +6 | xargs -r rm -rf
log "✅ Old releases cleaned up."

log "✅ Deployment script finished."
