#!/bin/bash

# Git branch watcher for auto-deployment with error recovery
set -e

# Configuration
BRANCH="Dev"
PROJECT_DIR="/home/banumath/Projects/yukina"
CHECK_INTERVAL=30 # seconds
LOG_FILE="$PROJECT_DIR/git-watcher.log"
MAX_CONSECUTIVE_FAILURES=3
consecutive_failures=0

log() {
    echo "$(date): $1" >> $LOG_FILE
}

# Initialize
cd $PROJECT_DIR
LAST_COMMIT=$(git rev-parse origin/$BRANCH)

log "👀 Starting Git watcher for branch: $BRANCH"
log "📁 Project directory: $PROJECT_DIR"
log "⏰ Check interval: $CHECK_INTERVAL seconds"
log "🔍 Initial commit: $LAST_COMMIT"

while true; do
    # Fetch latest changes
    git fetch origin > /dev/null 2>&1
    
    # Get current commit on remote
    CURRENT_COMMIT=$(git rev-parse origin/$BRANCH)
    
    if [ "$CURRENT_COMMIT" != "$LAST_COMMIT" ]; then
        log "🔄 New commit detected: $CURRENT_COMMIT"
        log "📝 Commit message: $(git log -1 --pretty=%B origin/$BRANCH)"
        
        # Run deployment
        if $PROJECT_DIR/deploy.sh; then
            log "✅ Deployment completed successfully"
            LAST_COMMIT=$CURRENT_COMMIT
            consecutive_failures=0
        else
            log "❌ Deployment failed"
            ((consecutive_failures++))
            
            if [ $consecutive_failures -ge $MAX_CONSECUTIVE_FAILURES ]; then
                log "🚨 Too many consecutive failures ($consecutive_failures). Pausing deployments for 5 minutes."
                sleep 300 # 5 minutes
                consecutive_failures=0
            fi
        fi
    fi
    
    sleep $CHECK_INTERVAL
done