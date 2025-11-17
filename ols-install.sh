#!/bin/bash

# OpenLiteSpeed + MySQL + PHP Installation Script
# For Ubuntu/Debian systems
# Run as root or with sudo

set -e

echo "=================================="
echo "OpenLiteSpeed Installation Script"
echo "=================================="
echo ""

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
else
    echo "Cannot detect OS. Exiting."
    exit 1
fi

echo "Detected OS: $OS $VER"
echo ""

# Update system
echo "Updating system packages..."
apt-get update && apt-get upgrade -y

# Install OpenLiteSpeed Repository
echo "Adding OpenLiteSpeed repository..."
wget -O - https://repo.litespeed.sh | bash

# Install OpenLiteSpeed
echo "Installing OpenLiteSpeed..."
apt-get install openlitespeed -y

# Install PHP (lsphp81 - PHP 8.1, you can change version)
echo "Installing PHP 8.1..."
apt-get install lsphp81 lsphp81-common lsphp81-mysql lsphp81-opcache lsphp81-curl lsphp81-imagick lsphp81-imap lsphp81-intl lsphp81-memcached lsphp81-redis -y

# Create symbolic link for PHP
ln -sf /usr/local/lsws/lsphp81/bin/php /usr/bin/php

# Install MySQL
echo "Installing MySQL Server..."
apt-get install mysql-server -y

# Secure MySQL installation (automated)
echo "Securing MySQL installation..."
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'ChangeThisPassword123!';"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
mysql -e "FLUSH PRIVILEGES;"

# Set OpenLiteSpeed admin password
echo "Setting OpenLiteSpeed admin password..."
ADMIN_PASS=$(openssl rand -base64 12)
/usr/local/lsws/admin/misc/admpass.sh <<EOF
admin
$ADMIN_PASS
$ADMIN_PASS
EOF

# Enable and start services
echo "Starting services..."
systemctl enable lsws
systemctl start lsws
systemctl enable mysql
systemctl start mysql

# Get server IP
SERVER_IP=$(curl -s ifconfig.me)

# Display credentials
echo ""
echo "=================================="
echo "Installation Complete!"
echo "=================================="
echo ""
echo "OpenLiteSpeed WebAdmin:"
echo "  URL: https://$SERVER_IP:7080"
echo "  Username: admin"
echo "  Password: $ADMIN_PASS"
echo ""
echo "MySQL Root Password: ChangeThisPassword123!"
echo ""
echo "Default Website:"
echo "  URL: http://$SERVER_IP:8088"
echo ""
echo "IMPORTANT: Save these credentials securely!"
echo "Change the MySQL root password after first login."
echo ""
echo "Next Steps:"
echo "1. Access WebAdmin and change the default port (8088) to 80"
echo "2. Install WordPress using LSCache plugin"
echo "3. Configure SSL certificate"
echo ""
