#!/bin/bash

echo "🚀 Starting KMP REST Web App..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a port is in use
check_port() {
    local port=$1
    lsof -i :$port >/dev/null 2>&1
}

# Function to wait for a port to be available
wait_for_port() {
    local port=$1
    local service=$2
    local max_attempts=30
    local attempt=0
    
    echo "  Waiting for $service on port $port..."
    while ! check_port $port && [ $attempt -lt $max_attempts ]; do
        sleep 1
        attempt=$((attempt + 1))
        if [ $((attempt % 5)) -eq 0 ]; then
            echo "    Still waiting... (${attempt}s)"
        fi
    done
    
    if [ $attempt -eq $max_attempts ]; then
        echo "❌ $service failed to start on port $port"
        return 1
    else
        echo "✅ $service is running on port $port"
        return 0
    fi
}

# Check for required tools
echo "🔍 Checking prerequisites..."
if ! command_exists java; then
    echo "❌ Error: Java is not installed or not in PATH"
    echo "   Please install Java 17+ and try again"
    exit 1
fi

if ! command_exists ./gradlew; then
    echo "❌ Error: Gradle wrapper not found"
    echo "   Please run this script from the project root directory"
    exit 1
fi

echo "✅ Prerequisites check passed"

# Clean up any existing processes
echo "🧹 Cleaning up existing processes..."
./stop.sh > /dev/null 2>&1

# Build the project first
echo "🔨 Building project..."
./gradlew build --quiet
if [ $? -ne 0 ]; then
    echo "❌ Build failed. Please check the build errors above."
    exit 1
fi
echo "✅ Project built successfully"

# Start backend server
echo "🖥️  Starting backend server..."
./gradlew :backend:run > backend.log 2>&1 &
BACKEND_PID=$!

# Wait for backend to start
if wait_for_port 8081 "Backend API"; then
    echo "   Backend logs: tail -f backend.log"
else
    echo "❌ Backend failed to start. Check backend.log for details."
    kill $BACKEND_PID 2>/dev/null || true
    exit 1
fi

# Start frontend development server
echo "🌐 Starting frontend development server..."
./gradlew :frontend:wasmJsBrowserDevelopmentRun > frontend.log 2>&1 &
FRONTEND_PID=$!

# Wait for frontend to start
if wait_for_port 8080 "Frontend"; then
    echo "   Frontend logs: tail -f frontend.log"
else
    echo "❌ Frontend failed to start. Check frontend.log for details."
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null || true
    exit 1
fi

# Save PIDs to a file for stop script
echo "$BACKEND_PID" > .running.pid
echo "$FRONTEND_PID" >> .running.pid

echo ""
echo "🎉 All services started successfully!"
echo ""
echo "📱 Frontend (Kotlin/Wasm):     http://localhost:8080"
echo "🖥️  Backend API:               http://localhost:8081"
echo "🩺 Backend Health Check:       http://localhost:8081/api/health"
echo "📊 API Info:                   http://localhost:8081/api/info"
echo ""
echo "📋 Management Commands:"
echo "   Stop all services:          ./stop.sh"
echo "   View backend logs:          tail -f backend.log"
echo "   View frontend logs:         tail -f frontend.log"
echo "   Check running processes:    ps aux | grep -E '(gradlew|java.*backend|webpack)'"
echo ""
echo "🔗 Test the application by opening http://localhost:8080 in your browser!"
echo "   The frontend should show 'Backend Status: Healthy' if everything is working." 