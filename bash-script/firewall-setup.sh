# #!/bin/bash

# echo "Setting up firewall configuration..."

# # Check if ufw is installed
# if ! command -v ufw &> /dev/null; then
#     echo "Installing ufw..."
#     apt-get update -qq
#     apt-get install -y ufw
# fi

# # Reset ufw to defaults
# echo "Resetting firewall to defaults..."
# ufw --force reset

# # Default policies
# ufw default deny incoming
# ufw default allow outgoing

# # Allow SSH (important - don't lock yourself out!)
# ufw allow ssh
# ufw allow 22/tcp

# # Allow HTTP and HTTPS
# ufw allow 80/tcp
# ufw allow 443/tcp

# # Allow Nomad ports
# ufw allow 4646/tcp  # Nomad HTTP API
# ufw allow 4647/tcp  # Nomad RPC
# ufw allow 4648/tcp  # Nomad Serf WAN

# # Allow Consul ports (if using)
# ufw allow 8500/tcp  # Consul HTTP API
# ufw allow 8600/tcp  # Consul DNS
# ufw allow 8600/udp  # Consul DNS

# # Allow Node Exporter
# ufw allow 9100/tcp

# # Allow your Go app port (assuming it will use 8080)
# ufw allow 8080/tcp

# # Enable firewall
# echo "Enabling firewall..."
# ufw --force enable

# # Show status
# echo "Firewall configuration complete:"
# ufw status verbose

# echo "Firewall setup completed successfully!"