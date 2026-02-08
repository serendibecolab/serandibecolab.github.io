#!/bin/bash

# Initial setup script for a new Linux server to deploy the Astro static site.
# This script will install necessary dependencies, configure Nginx, and
# perform the first deployment.
#
# This script assumes the project repository has already been cloned
# to the location where this script resides (e.g., PROJECT_ROOT/scripts/initial-setup.sh).

set -e

echo "🚀 Starting initial server setup..."

# --- Configuration ---
# PROJECT_ROOT is now relative to the script's location
PROJECT_ROOT="$(dirname "$(readlink -f "$0")")/.."
BRANCH="Dev" # The branch to deploy
DOMAIN="serendibecolab.com" # Your domain name for Nginx configuration
NGINX_CONFIG_PATH="/etc/nginx/sites-available/$DOMAIN"
NGINX_SYMLINK_PATH="/etc/nginx/sites-enabled/$DOMAIN"
LIVE_DIR="$PROJECT_ROOT/deploy/current" # Nginx root will point here

# --- Functions ---
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

error_exit() {
    log "❌ ERROR: $1"
    exit 1
}

# --- Pre-checks ---
if [ "$(id -u)" -ne 0 ]; then
    error_exit "This script must be run with sudo privileges."
fi

# Detect OS and set package manager
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    error_exit "Cannot detect operating system. /etc/os-release not found."
fi

log "Detected OS: $OS"

# --- Step 1: Update System Packages ---
log "Updating system packages..."
case "$OS" in
    ubuntu|debian)
        apt update -y || error_exit "Failed to update system packages."
        apt upgrade -y || error_exit "Failed to upgrade system packages."
        ;;
    fedora)
        dnf check-update -y || error_exit "Failed to check for dnf updates."
        dnf upgrade -y || error_exit "Failed to upgrade system packages."
        ;;
    arch)
        pacman -Syu --noconfirm || error_exit "Failed to update Arch system packages."
        ;;
    *)
        error_exit "Unsupported OS: $OS. Please add support for your distribution."
        ;;
esac

# --- Step 2: Install Git ---
log "Installing Git..."
case "$OS" in
    ubuntu|debian)
        apt install -y git || error_exit "Failed to install Git."
        ;;
    fedora)
        dnf install -y git || error_exit "Failed to install Git."
        ;;
    arch)
        pacman -S --noconfirm git curl || error_exit "Failed to install Git and Curl."
        ;;
esac

# --- Step 3: Install Node.js (LTS) and pnpm ---
log "Installing Node.js (LTS) and pnpm..."
case "$OS" in
    ubuntu|debian)
        curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - || error_exit "Failed to add NodeSource PPA."
        apt install -y nodejs || error_exit "Failed to install Node.js."
        ;;
    fedora)
        dnf install -y nodejs || error_exit "Failed to install Node.js."
        ;;
    arch)
        pacman -S --noconfirm nodejs npm || error_exit "Failed to install Node.js and npm."
        ;;
esac

# Install pnpm universally
log "Installing pnpm..."
curl -fsSL https://get.pnpm.io/install.sh | sh - || error_exit "Failed to install pnpm."
# Add pnpm to PATH for the current session
export PNPM_HOME="/root/.local/share/pnpm" # Assuming root user for sudo script
export PATH="$PNPM_HOME:$PATH"

# --- Step 4: Install Nginx ---
log "Installing Nginx..."
case "$OS" in
    ubuntu|debian)
        apt install -y nginx || error_exit "Failed to install Nginx."
        ;;
    fedora)
        dnf install -y nginx || error_exit "Failed to install Nginx."
        systemctl enable nginx || error_exit "Failed to enable Nginx service."
        ;;
    arch)
        pacman -S --noconfirm nginx || error_exit "Failed to install Nginx."
        systemctl enable nginx || error_exit "Failed to enable Nginx service."
        ;;
esac

# --- Step 5: Configure Nginx ---
log "Configuring Nginx for $DOMAIN..."

# Create Nginx server block configuration
cat <<EOF > "$NGINX_CONFIG_PATH"
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN www.$DOMAIN;

    root $LIVE_DIR;
    index index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    # Optional: Add caching headers for static assets
    location ~* \.(css|js|gif|jpe?g|png|webp|svg|eot|ttf|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, no-transform";
        try_files \$uri =404;
    }
}
EOF

# Enable the site by creating a symlink
ln -sfn "$NGINX_CONFIG_PATH" "$NGINX_SYMLINK_PATH" || error_exit "Failed to enable Nginx site."

# Remove default Nginx site to avoid conflicts
if [ -f "/etc/nginx/sites-enabled/default" ]; then
    rm "/etc/nginx/sites-enabled/default" || log "Could not remove default Nginx site (might not exist)."
fi

# Test Nginx configuration
nginx -t || error_exit "Nginx configuration test failed. Check $NGINX_CONFIG_PATH."

# Reload Nginx to apply changes
systemctl reload nginx || error_exit "Failed to reload Nginx."

# --- Step 6: Perform Initial Deployment ---
log "Performing initial deployment using deploy.sh..."
cd "$PROJECT_ROOT" || error_exit "Failed to change to project directory."
# Ensure deploy.sh is executable
chmod +x "$PROJECT_ROOT/scripts/deploy.sh" || error_exit "Failed to make deploy.sh executable."
"$PROJECT_ROOT/scripts/deploy.sh" "$BRANCH" || error_exit "Initial deployment failed."

# --- Step 7: Enable and Start Nginx Service ---
log "Enabling and starting Nginx service..."
systemctl enable nginx || error_exit "Failed to enable Nginx service."
systemctl start nginx || error_exit "Failed to start Nginx service."

# --- Step 8: Configure and Start Yukina Watcher Service ---
log "Configuring and starting Yukina Git Auto-Deploy Watcher service..."

WATCHER_SERVICE_FILE="$PROJECT_ROOT/yukina-watcher.service"
GIT_WATCHER_SCRIPT="$PROJECT_ROOT/scripts/git-watcher.sh"
SYSTEMD_SERVICE_PATH="/etc/systemd/system/yukina-watcher.service"

# Ensure git-watcher.sh is executable
chmod +x "$GIT_WATCHER_SCRIPT" || error_exit "Failed to make git-watcher.sh executable."

# Create the service file content dynamically
cat <<EOF > "$SYSTEMD_SERVICE_PATH"
[Unit]
Description=Yukina Git Auto-Deploy Watcher
After=network.target

[Service]
Type=simple
# User=your_deploy_user # IMPORTANT: Consider running this service as a dedicated, unprivileged user for security.
# If you uncomment the above line, ensure the user exists and has appropriate permissions.
WorkingDirectory=$PROJECT_ROOT
ExecStart=$GIT_WATCHER_SCRIPT
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload || error_exit "Failed to reload systemd daemon."
systemctl enable yukina-watcher.service || error_exit "Failed to enable yukina-watcher.service."
systemctl start yukina-watcher.service || error_exit "Failed to start yukina-watcher.service."
log "✅ Yukina Git Auto-Deploy Watcher service configured and started."

# --- Step 9: Display Public IP ---
log "Attempting to retrieve public IP address..."
PUBLIC_IP=$(curl -s ifconfig.me)
if [ -n "$PUBLIC_IP" ]; then
    log "✅ Public IP Address: $PUBLIC_IP"
else
    log "⚠️ Could not retrieve public IP address. Please check manually."
fi

log "✅ Initial server setup completed successfully!"
log "Your site should now be accessible at http://$DOMAIN"
log "Remember to update your DNS records to point to this server's IP address."
log "!!! IMPORTANT: Ensure the project repository is cloned to the location where this script is run from (e.g., PROJECT_ROOT/scripts/initial-setup.sh) before executing this script. !!!"
log "!!! IMPORTANT: Review the 'User' directive in $SYSTEMD_SERVICE_PATH for security best practices. !!!"
