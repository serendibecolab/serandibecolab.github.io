#!/bin/bash

# This script is for local preview of the built static site.
# For production, Nginx or Apache should serve the 'dist/' directory.

PORT=${1:-3000}

echo "🚀 Starting static site preview on port $PORT..."
# Ensure 'serve' is installed globally or available via npx
npx serve dist -l $PORT