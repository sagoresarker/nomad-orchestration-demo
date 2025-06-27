job "go-app" {
  datacenters = ["dc1"]
  type        = "service"

  group "app" {
    count = 1

    network {
      port "http" {
        static = 8080
      }
    }

    task "go-binary" {
      driver = "raw_exec"

            config {
        command = "/bin/bash"
        args    = ["local/run-app.sh"]
      }

      # Script to copy and run the binary
      template {
        data = <<EOH
#!/bin/bash
echo "Setting up Go application..."

# Copy the binary to task directory
cp /root/poridhi/nomad-test/nomad-job/go-app/app ./app
chmod +x ./app

echo "Starting Go application..."
# Run the Go binary
exec ./app
EOH
        destination = "local/run-app.sh"
        perms       = "755"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}