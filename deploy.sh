#!/bin/bash
set -e

echo "=== PrestaShop Server Setup ==="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
    echo "Docker installed. You may need to log out and back in."
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    echo "Docker Compose plugin not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin
fi

# Clone or update repo
APP_DIR="/opt/prestashop"
if [ ! -d "$APP_DIR" ]; then
    echo "Cloning repository..."
    sudo mkdir -p $APP_DIR
    sudo chown $USER:$USER $APP_DIR
    git clone https://github.com/WoompaLoompa/PrestaShop.git $APP_DIR
    cd $APP_DIR
    git checkout develop
else
    echo "Repository exists. Pulling latest..."
    cd $APP_DIR
    git pull origin develop
fi

# Copy .env if it doesn't exist
if [ ! -f .env ]; then
    cp .env.example .env
    echo ""
    echo "!!! Edit .env with your settings before starting !!!"
    echo "    nano $APP_DIR/.env"
    echo ""
    exit 0
fi

# Start services
echo "Starting PrestaShop..."
docker compose -f docker-compose.prod.yml up -d

echo ""
echo "=== PrestaShop Deployed ==="
echo "Front-office: http://${PS_DOMAIN:-prestashop-clink.is-a.dev}/"
echo "Back-office:  http://${PS_DOMAIN:-prestashop-clink.is-a.dev}/admin-dev"
echo ""
echo "Login: ${ADMIN_MAIL:-admin@atomicmail.io}"
echo "Pass:  ${ADMIN_PASSWD:-Pr3st4Sh0P}"
