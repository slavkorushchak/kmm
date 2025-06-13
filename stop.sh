#!/bin/bash

echo "🛑 Stopping KMP REST Web App services..."

# Function to kill processes on specific ports
kill_port() {
    local port=$1
    local pids=$(lsof -ti:$port 2>/dev/null)
    if [ ! -z "$pids" ]; then
        echo "  Killing processes on port $port: $pids"
        echo $pids | xargs kill -9 2>/dev/null || true
    fi
}

# Kill processes using our specific ports
echo "📡 Stopping servers on ports 8080 and 8081..."
kill_port 8080
kill_port 8081

# Kill Gradle processes related to our project
echo "⚙️  Stopping Gradle processes..."
pkill -f "gradlew.*backend:run" 2>/dev/null || true
pkill -f "gradlew.*frontend.*wasmJsBrowserDevelopmentRun" 2>/dev/null || true
pkill -f "java.*backend" 2>/dev/null || true
pkill -f "java.*frontend" 2>/dev/null || true

# Kill webpack dev server processes
echo "📦 Stopping webpack processes..."
pkill -f "webpack-dev-server" 2>/dev/null || true
pkill -f "node.*webpack" 2>/dev/null || true

# Kill any remaining Node.js processes that might be related
pkill -f "node.*8080" 2>/dev/null || true

# Kill envoy if running
pkill -f "envoy" 2>/dev/null || true

# If we have a PID file, kill those processes too
if [ -f .running.pid ]; then
    echo "📄 Cleaning up PID file..."
    while read pid; do
        kill -9 $pid 2>/dev/null || true
    done < .running.pid
    rm .running.pid
fi

# Wait a moment for processes to terminate
sleep 2

# Verify ports are free
echo "🔍 Verifying ports are free..."
if lsof -ti:8080 >/dev/null 2>&1; then
    echo "⚠️  Warning: Port 8080 still in use"
    lsof -ti:8080 | xargs kill -9 2>/dev/null || true
else
    echo "✅ Port 8080 is free"
fi

if lsof -ti:8081 >/dev/null 2>&1; then
    echo "⚠️  Warning: Port 8081 still in use"
    lsof -ti:8081 | xargs kill -9 2>/dev/null || true
else
    echo "✅ Port 8081 is free"
fi

# Clean build artifacts
echo "🧹 Cleaning build artifacts..."
./gradlew clean --quiet

# Stop any remaining Gradle daemons
echo "🔄 Stopping Gradle daemons..."
./gradlew --stop --quiet

echo "✅ All services stopped successfully!"
echo "🚀 Ready to restart with: ./start.sh" 