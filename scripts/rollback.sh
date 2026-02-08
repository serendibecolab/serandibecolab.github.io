#!/bin/bash

# Manual rollback script for Astro Static Site Generation (SSG)
set -e

PROJECT_DIR="$(dirname "$(readlink -f "$0")")/.." # Project root is parent of script directory
DEPLOY_DIR="$PROJECT_DIR/deploy"
LOG_FILE="$PROJECT_DIR/deploy.log"
WEB_SERVER_SERVICE="nginx" # Your web server service name

log() {
    echo "$(date): $1" >> $LOG_FILE
    echo "$1"
}

# Get available deployments
get_deployments() {
    ls -dt $DEPLOY_DIR/build_* 2>/dev/null || echo ""
}

# Rollback to specific deployment
rollback_to() {
    local target_deploy_path=$1
    
    if [ ! -d "$target_deploy_path" ]; then
        log "❌ Deployment not found: $target_deploy_path"
        exit 1
    fi
    
    log "🔄 Rolling back to: $(basename $target_deploy_path)"
    
    # Update the 'current' symlink to point to the rolled back deployment
    ln -sfn "$target_deploy_path" "$DEPLOY_DIR/current" || log "❌ Failed to update current symlink for rollback."

    # Reload the web server to serve new files
    log "🌐 Reloading $WEB_SERVER_SERVICE to serve previous content (via symlink)..."
    sudo systemctl reload $WEB_SERVER_SERVICE || log "❌ Failed to reload $WEB_SERVER_SERVICE. Check its status."
    
    log "✅ Rollback completed to: $(basename $target_deploy_path)"
    echo "💡 IMPORTANT: Ensure your Nginx configuration 'root' directive points to: $DEPLOY_DIR/current"
}

# Main rollback function
main() {
    local target_deployment_name=$1 # The deployment name is the first argument
    
    if [ -z "$target_deployment_name" ]; then
        # Rollback to previous deployment (excluding the current one)
        DEPLOYMENTS=($(get_deployments))
        if [ ${#DEPLOYMENTS[@]} -lt 2 ]; then
            log "❌ Not enough deployments for automatic rollback (need at least 2)."
            exit 1
        fi
        
        CURRENT_SYMLINK_TARGET=$(readlink -f "$DEPLOY_DIR/current")
        PREVIOUS_DEPLOY_PATH=""
        
        for deploy_path in "${DEPLOYMENTS[@]}"; do
            if [ "$deploy_path" != "$CURRENT_SYMLINK_TARGET" ]; then
                PREVIOUS_DEPLOY_PATH="$deploy_path"
                break
            fi
        done
        
        if [ -n "$PREVIOUS_DEPLOY_PATH" ]; then
            rollback_to "$PREVIOUS_DEPLOY_PATH"
        else
            log "❌ No previous deployment found for automatic rollback."
            exit 1
        fi
    else
        # Rollback to specific deployment
        if [[ "$target_deployment_name" == build_* ]]; then
            rollback_to "$DEPLOY_DIR/$target_deployment_name"
        else
            log "❌ Invalid deployment format. Use: build_YYYYMMDD_HHMMSS"
            exit 1
        fi
    fi
}

# List deployments if no args
if [ $# -eq 0 ]; then
    echo "Available deployments:"
    get_deployments | while read deploy; do
        base=$(basename "$deploy")
        if [ "$(readlink -f "$DEPLOY_DIR/current")" = "$deploy" ]; then
            echo "  ✅ $base (current)"
        else
            echo "  📁 $base"
        fi
    done
    echo ""
    echo "Usage: $0 [deployment_name]"
    echo "Example: $0 build_20241215_143022"
    echo "Example: $0 (to rollback to previous deployment)"
    exit 0
fi

main "$1"
