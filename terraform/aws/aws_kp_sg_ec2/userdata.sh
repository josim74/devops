#!/bin/bash
# Update the package index
sudo apt-get update

# Install Apache
sudo apt-get install -y apache2

# Start Apache
sudo systemctl start apache2
sudo systemctl enable apache2

# Create a simple webpage
echo "<html><body><h1>Hello, World!</h1></body></html>" > /var/www/html/index.html
