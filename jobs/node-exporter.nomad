job "node-exporter" {
  datacenters = ["dc1"]
  type        = "service"

  group "monitoring" {
    count = 1

    network {
      port "metrics" {
        static = 9100
      }
    }

    task "node-exporter" {
      driver = "raw_exec"

      config {
        command = "/bin/bash"
        args    = ["/root/poridhi/nomad-test/nomad-job/bash-script/node-exporter.sh"]
      }

      # Setup script following the provided guide
      template {
                data = <<EOH
#!/bin/bash

# Node Exporter setup script following the guide
echo "Setting up Node Exporter v1.9.1..."

# Create directory if it doesn't exist
mkdir -p /opt

# Download Node Exporter v1.9.1 if not exists
if [ ! -f "/opt/node_exporter/node_exporter" ]; then
    echo "Downloading Node Exporter v1.9.1..."
    cd /opt
    wget -q https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz
    tar xzf node_exporter-1.9.1.linux-amd64.tar.gz
    mv node_exporter-1.9.1.linux-amd64 node_exporter
    rm -f node_exporter-1.9.1.linux-amd64.tar.gz
    chmod +x /opt/node_exporter/node_exporter
fi

echo "Starting Node Exporter on port 9100..."
# Run Node Exporter directly
exec /opt/node_exporter/node_exporter --web.listen-address=:9100
EOH
        destination = "/root/poridhi/nomad-test/nomad-job/bash-script/node-exporter.sh"
        perms       = "755"
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}