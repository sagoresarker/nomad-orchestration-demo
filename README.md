# Nomad Testing Setup

This repository contains three Nomad jobs to test different Nomad features:

1. **Node Exporter Service** - Long-running monitoring service
2. **Go Binary Application** - Custom Go application running as a service
3. **Firewall Setup** - One-time batch job to configure firewall

## 📁 Directory Structure

```
nomad-job/
├── jobs/
│   ├── node-exporter.nomad    # Node Exporter service job
│   ├── go-app.nomad          # Go binary application job
│   └── firewall-setup.nomad  # Firewall setup batch job
├── go-app/
│   ├── main.go               # Go source code
│   ├── go.mod               # Go module file
│   └── app                  # Compiled Go binary
├── bash-script/
│   ├── node-exporter.sh     # Node Exporter setup script
│   ├── firewall-setup.sh    # Firewall configuration script
│   └── setup.sh            # Original setup script
└── run-all-jobs.sh          # Job management helper script
```

## 🚀 Quick Start

### Prerequisites

1. **Nomad Agent Running**: Make sure Nomad agent is running
   ```bash
   # Start Nomad in dev mode (for testing)
   sudo nomad agent -dev -bind=0.0.0.0
   ```

2. **Root Privileges**: Some jobs require root privileges (firewall setup, raw_exec driver)

### Running All Jobs

```bash
cd nomad-job
./run-all-jobs.sh run-all
```

This will:
1. Run firewall setup (batch job)
2. Start Node Exporter service
3. Start Go application service

## 📊 Job Details

### 1. Node Exporter Service (`node-exporter.nomad`)

- **Type**: Service (long-running)
- **Port**: 9100
- **Driver**: raw_exec
- **Features**:
  - Downloads and runs Node Exporter binary
  - Exposes metrics on port 9100
  - Health checks via HTTP endpoint
  - Auto-restart on failure

### 2. Go Application (`go-app.nomad`)

- **Type**: Service (long-running)
- **Port**: 8080
- **Driver**: raw_exec
- **Features**:
  - Runs pre-compiled Go binary
  - TCP health checks
  - Resource constraints (100 CPU, 128MB RAM)

### 3. Firewall Setup (`firewall-setup.nomad`)

- **Type**: Batch (one-time execution)
- **Driver**: raw_exec
- **Features**:
  - Installs and configures UFW
  - Opens necessary ports for Nomad, services
  - Completes and exits

## 🛠️ Management Commands

### Check Job Status
```bash
./run-all-jobs.sh status
```

### Check Service Health
```bash
./run-all-jobs.sh check
```

### View Job Logs
```bash
./run-all-jobs.sh logs node-exporter
./run-all-jobs.sh logs go-app
./run-all-jobs.sh logs firewall-setup
```

### Stop All Jobs
```bash
./run-all-jobs.sh stop-all
```

## 🔍 Manual Testing

### Test Node Exporter
```bash
# Check if Node Exporter is running
curl http://localhost:9100/metrics

# Should return system metrics
```

### Test Go Application
```bash
# Check if Go app is running
nc -z localhost 8080
echo $?  # Should return 0 if running

# Check process
ps aux | grep app
```

### Test Firewall
```bash
# Check firewall status
sudo ufw status verbose

# Should show enabled with proper rules
```

## 📋 Individual Job Execution

If you want to run jobs individually:

```bash
cd nomad-job

# Run firewall setup
nomad job run jobs/firewall-setup.nomad

# Run Node Exporter
nomad job run jobs/node-exporter.nomad

# Run Go application
nomad job run jobs/go-app.nomad
```

## 🔧 Troubleshooting

### Common Issues

1. **Nomad Agent Not Running**
   ```bash
   # Check if Nomad is running
   nomad node status

   # Start Nomad in dev mode
   sudo nomad agent -dev -bind=0.0.0.0
   ```

2. **Permission Denied (raw_exec driver)**
   ```bash
   # Ensure Nomad is running with proper privileges
   # Check Nomad client configuration allows raw_exec
   ```

3. **Port Already in Use**
   ```bash
   # Check what's using the port
   sudo netstat -tlnp | grep :9100
   sudo netstat -tlnp | grep :8080

   # Kill conflicting processes if needed
   ```

4. **Firewall Blocking Access**
   ```bash
   # Check firewall rules
   sudo ufw status

   # Add rules if needed
   sudo ufw allow 9100/tcp
   sudo ufw allow 8080/tcp
   ```

## 🔐 Security Notes

- The firewall job opens standard ports for Nomad and services
- Node Exporter exposes system metrics (consider access control in production)
- raw_exec driver runs with full system privileges
- SSH access is preserved in firewall configuration

## 📈 Monitoring

After running the jobs, you can monitor:

- **Nomad UI**: http://localhost:4646 (if running)
- **Node Exporter**: http://localhost:9100/metrics
- **Job Status**: Use the management script or Nomad CLI

## 🎯 Testing Scenarios

This setup tests:

1. **Service Discovery**: Jobs register with Nomad's service discovery
2. **Health Checks**: Both HTTP and TCP health checks
3. **Resource Management**: CPU and memory constraints
4. **Network Configuration**: Static port assignments
5. **Batch Jobs**: One-time execution with firewall setup
6. **Binary Execution**: Running compiled Go binaries
7. **Script Execution**: Running bash scripts via Nomad