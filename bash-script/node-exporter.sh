#!/bin/bash

# Node Exporter setup and run script
echo "Setting up Node Exporter..."

# Download Node Exporter if not exists
if [ ! -f "/tmp/node_exporter" ]; then
    echo "Downloading Node Exporter..."
    cd /tmp
    wget -q https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
    tar xzf node_exporter-1.8.2.linux-amd64.tar.gz
    cp node_exporter-1.8.2.linux-amd64/node_exporter .
    chmod +x node_exporter
    rm -rf node_exporter-1.8.2.linux-amd64*
fi

echo "Starting Node Exporter on port 9100..."
# Run Node Exporter
exec /tmp/node_exporter --web.listen-address=:9100