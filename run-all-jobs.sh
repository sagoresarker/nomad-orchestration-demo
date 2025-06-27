#!/bin/bash

# Helper script to run and manage all Nomad jobs
echo "=========================================="
echo "Nomad Job Management Script"
echo "=========================================="

# Function to check if Nomad is running
check_nomad() {
    if ! command -v nomad &> /dev/null; then
        echo "❌ Nomad is not installed or not in PATH"
        exit 1
    fi

    if ! nomad node status &> /dev/null; then
        echo "❌ Nomad agent is not running or not accessible"
        echo "Please start Nomad agent first"
        exit 1
    fi

    echo "✅ Nomad is running"
}

# Function to run a job
run_job() {
    local job_file=$1
    local job_name=$2

    echo "🚀 Running job: $job_name"
    if nomad job run jobs/$job_file; then
        echo "✅ Job $job_name submitted successfully"
    else
        echo "❌ Failed to submit job $job_name"
        return 1
    fi
}

# Function to check job status
check_job_status() {
    local job_name=$1
    echo "📊 Status of job: $job_name"
    nomad job status $job_name
    echo ""
}

# Function to show all jobs
show_all_jobs() {
    echo "📋 All Nomad jobs:"
    nomad job status
    echo ""
}

# Function to show node status
show_node_status() {
    echo "🖥️  Node status:"
    nomad node status
    echo ""
}

# Function to check services
check_services() {
    echo "🔍 Checking services..."

    echo "Node Exporter (port 9100):"
    if curl -s http://localhost:9100/metrics | head -n 5; then
        echo "✅ Node Exporter is running"
    else
        echo "❌ Node Exporter is not accessible"
    fi
    echo ""

    echo "Go App (port 8080):"
    if nc -z localhost 8080; then
        echo "✅ Go App is running on port 8080"
    else
        echo "❌ Go App is not accessible on port 8080"
    fi
    echo ""

    echo "Firewall status:"
    if command -v ufw &> /dev/null; then
        ufw status
    else
        echo "UFW not installed"
    fi
}

# Main menu
case "$1" in
    "run-all")
        check_nomad
        echo "🎯 Running all jobs..."

        # Run firewall setup first (batch job)
        run_job "firewall-setup.nomad" "firewall-setup"
        sleep 2

        # Run Node Exporter
        run_job "node-exporter.nomad" "node-exporter"
        sleep 2

        # Run Go App
        run_job "go-app.nomad" "go-app"

        echo "🎉 All jobs submitted!"
        ;;

    "status")
        check_nomad
        show_all_jobs
        show_node_status
        ;;

    "check")
        check_nomad
        check_services
        ;;

    "stop-all")
        check_nomad
        echo "🛑 Stopping all jobs..."
        nomad job stop firewall-setup 2>/dev/null || true
        nomad job stop node-exporter 2>/dev/null || true
        nomad job stop go-app 2>/dev/null || true
        echo "✅ All jobs stopped"
        ;;

    "logs")
        if [ -z "$2" ]; then
            echo "Usage: $0 logs <job-name>"
            echo "Available jobs: firewall-setup, node-exporter, go-app"
            exit 1
        fi
        check_nomad
        echo "📝 Logs for job: $2"
        nomad alloc logs -job $2
        ;;

    *)
        echo "Usage: $0 {run-all|status|check|stop-all|logs <job-name>}"
        echo ""
        echo "Commands:"
        echo "  run-all    - Run all three jobs (firewall, node-exporter, go-app)"
        echo "  status     - Show status of all jobs and nodes"
        echo "  check      - Check if services are running and accessible"
        echo "  stop-all   - Stop all running jobs"
        echo "  logs       - Show logs for a specific job"
        echo ""
        echo "Examples:"
        echo "  $0 run-all"
        echo "  $0 status"
        echo "  $0 check"
        echo "  $0 logs node-exporter"
        ;;
esac