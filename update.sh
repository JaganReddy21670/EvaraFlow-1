#!/bin/bash
# RetroFit Image Capture Service - Simple OTA updater
set -e

echo "[1/3] Stopping service..."
sudo systemctl stop retrofit-capture.service || true

echo "[2/3] Pulling latest changes from GitHub..."
git pull

echo "[3/3] Synchronizing environment..."
# Check if resolving via Docker native configs
if [ -f "docker-compose.yml" ] && command -v docker-compose &> /dev/null; then
    echo "   -> Docker environment detected..."
    docker-compose down
    docker-compose build
    docker-compose up -d
else
    echo "   -> Native environment detected..."
    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi
    source venv/bin/activate
    pip install -r requirements.txt
    deactivate

    echo "   -> Restarting systemd service..."
    sudo systemctl start retrofit-capture.service
fi

echo "Update complete!"
