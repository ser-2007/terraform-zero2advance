#!/bin/bash
sudo apt-get update
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar xvfz node_exporter-*.tar.gz
sudo mv node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin
rm -r node_exporter-1.5.0.linux-amd64*
sudo useradd -rs /bin/false node_exporter
cat << 'EOF' > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Nginx server installation
#sudo apt-get update
#sudo apt-get install nginx -y
# Create a simple HTML file
#echo '<html><head><title>Hello World! I am Nginx Server</title></head><body><h1>Hello, World NGINX_SERVER!</h1></body></html>' | sudo tee /var/www/html/index.html
sudo systemctl enable node_exporter
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl status node_exporter