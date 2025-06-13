# Kotlin Multiplatform REST Web App

## Overview

This project is a Kotlin Multiplatform (KMP) application that demonstrates the integration of a WebAssembly-based frontend with a REST API backend using shared Kotlin code. The frontend contains a single button labeled **Fetch Data**. When clicked, it sends a REST request to the backend, which responds with dummy data. The data is then rendered in the UI using Material3 design components.

**🚀 Current Status:** Backend and Frontend fully implemented and operational! Both services running successfully with complete build pipeline and REST API integration.

---

## Quick Start

### Prerequisites
- Java 17 or higher
- Gradle 8.12+

### Start the Application
```bash
# Start both backend and frontend servers
./start.sh

# Stop all services
./stop.sh
```

**Services:**
- **Backend API**: http://localhost:8081 (REST endpoints + health checks)
- **Frontend**: http://localhost:8080 (Kotlin/Wasm with Material3 UI)

---

## Objectives

- Demonstrate the use of Kotlin Multiplatform to build a full-stack web application with shared code
- Use Kotlin Multiplatform with Wasm target for the frontend  
- Use JVM backend with REST API endpoints
- Use modern Material3 design system for beautiful UI
- Showcase REST API communication by fetching and displaying dummy data  
- Leverage shared Kotlin code for data models, business logic, and constants
- Maintain a clean and modular code structure for future expansion  

---

## Architecture Overview

- **Shared Module**: KMP common Kotlin code including data models, business logic, and constants
- **Frontend**: Kotlin Multiplatform → Wasm target (compiled to WebAssembly, runs in the browser)  
- **Backend**: **Pure JVM** application with REST API using Ktor framework
- **Transport Protocol**: REST over HTTP with JSON serialization
- **Communication**: Shared data models ensure type-safe communication between frontend and backend
- **Build System**: Gradle (Kotlin DSL) with hybrid architecture (KMP for shared/frontend, pure JVM for backend)

### 🏗️ **Architecture Decision: REST API Implementation**

**Current Implementation:** REST API with JSON serialization

**Benefits:**
- ✅ Simple HTTP/JSON communication (no proxy needed)
- ✅ Browser-native fetch API support
- ✅ Standard REST conventions and HTTP status codes
- ✅ JSON content negotiation with Ktor
- ✅ Easy debugging with standard web developer tools
- ✅ CORS support for cross-origin requests

---

## Implementation Status

### ✅ **Phase 1: Shared Module Foundation** - **COMPLETE**
- ✅ KMP shared module with commonMain, jvmMain, wasmJsMain source sets
- ✅ Shared data models (`DummyData`, `DummyDataFactory`, `AppConstants`)
- ✅ Cross-platform compilation (JVM + Wasm targets)
- ✅ Kotlinx Serialization for JSON support

### ✅ **Phase 2: Backend Implementation** - **COMPLETE**
- ✅ **REST API Server** (Ktor) running on port 8081
  - ✅ `/api/dummy-data` endpoint returning JSON dummy data
  - ✅ Content negotiation with automatic JSON serialization
  - ✅ CORS configuration for cross-origin requests
  - ✅ Health check endpoint (`/health`)
  - ✅ Shared data models integration
- ✅ **Static File Serving** for development resources
- ✅ **Unified Server Configuration**
  - ✅ Single application entry point
  - ✅ Graceful shutdown handling
  - ✅ Configurable ports via command line

### ✅ **Phase 3: Frontend Implementation** - **COMPLETE**
- ✅ Compose Multiplatform for Web UI with Kotlin/Wasm target
- ✅ Material3 design system with modern components
- ✅ "Fetch Data" button with loading states and error handling
- ✅ REST API integration using browser fetch API
- ✅ Frontend development server running on port 8080
- ✅ WebAssembly compilation and webpack integration
- ✅ Shared data models for type-safe responses

### ✅ **Phase 4: Integration & Testing** - **COMPLETE**  
- ✅ End-to-end REST API communication working
- ✅ JSON serialization/deserialization with shared models
- ✅ Error handling and user feedback
- ✅ CORS configuration tested and working
- ✅ Development workflow with hot reload

### ✅ **Phase 5: Build & Deployment Tools** - **COMPLETE**
- ✅ Automated start/stop scripts
- ✅ Build verification and health checks
- ✅ Process management and port monitoring
- ✅ Log file management

---

## 🐳 Docker Configuration

### Container Architecture

This project includes full Docker containerization with multi-stage builds and production optimization:

- **Frontend Container**: nginx-alpine serving Kotlin/Wasm with proper WASM MIME types
- **Backend Container**: JRE runtime serving Ktor REST API
- **Orchestration**: Docker Compose for service coordination

### Docker Files

#### `Dockerfile.frontend`
```dockerfile
# Multi-stage build: Gradle build → nginx serve
FROM gradle:8.12-jdk17 AS build
# ... build stage ...

FROM nginx:alpine
# ... production serve with WASM support ...
```

#### `Dockerfile.backend`
```dockerfile
# Multi-stage build: Gradle build → JRE runtime
FROM gradle:8.12-jdk17 AS build
# ... build stage ...

FROM eclipse-temurin:17-jre
# ... optimized runtime ...
```

#### `docker-compose.yml`
```yaml
services:
  frontend:
    build: ./frontend
    ports: ["8080:80"]
  backend:
    build: ./backend
    ports: ["8081:8081"]
    environment:
      - KTOR_PORT=8081
```

### Key Features

- **Multi-stage builds** for minimal production images
- **WASM MIME type** configuration for proper WebAssembly serving
- **Health checks** and container monitoring
- **Optimized nginx** configuration with caching
- **Build optimization** with `.dockerignore`

---

## API Endpoints

### Backend REST API (Port 8081)

| Endpoint | Method | Description | Response |
|----------|--------|-------------|----------|
| `/health` | GET | Health check | `"OK"` |
| `/api/dummy-data` | GET | Fetch dummy data | JSON `DummyData` object |

**Example Response:**
```json
{
  "id": "abc123",
  "name": "Sample Item",
  "description": "This is a sample dummy data item"
}
```

---

## Project Structure

### 📁 Root Project Structure

```
kmm-rest-web-app/
├── README.md                 # Project documentation
├── build.gradle.kts          # Root build configuration
├── settings.gradle.kts       # Module inclusion & project settings
├── gradle.properties         # Gradle configuration properties
├── start.sh                  # ✅ Start both frontend and backend locally
├── stop.sh                   # ✅ Stop all local services
├── docker-compose.yml        # ✅ Docker orchestration configuration
├── .dockerignore            # ✅ Docker build optimization
├── gradle/
│   └── libs.versions.toml    # Version catalog (dependencies & plugins)
├── shared/                   # ✅ KMP shared module (COMPLETE)
├── frontend/                 # ✅ KMP frontend module (Wasm target) - COMPLETE
│   └── Dockerfile.frontend   # ✅ Frontend container configuration
└── backend/                  # ✅ Pure JVM backend module (COMPLETE)
    └── Dockerfile.backend    # ✅ Backend container configuration
```

### 🔄 Shared Module (`shared/`) ✅ **COMPLETE**

```
shared/
├── build.gradle.kts                    # ✅ Shared module build config (KMP)
└── src/
    └── commonMain/                     # ✅ Platform-agnostic code
        └── kotlin/
            └── com/kmm/shared/
                └── DummyDataModels.kt  # ✅ Shared data models and utilities
```

**Shared Module Contents:**
- ✅ **DummyData**: Cross-platform data model with Kotlinx Serialization
- ✅ **DummyDataFactory**: Sample data generation utilities  
- ✅ **AppConstants**: Shared configuration (ports, endpoints)
- ✅ **Cross-platform compilation**: JVM + Wasm targets supported

### 🌐 Frontend Module (`frontend/`) ✅ **COMPLETE**

```
frontend/
├── build.gradle.kts                    # ✅ Frontend build config (Kotlin/Wasm target)
├── build/
│   └── dist/wasmJs/productionExecutable/
│       ├── frontend.js                 # ✅ Generated JavaScript bundle
│       ├── *.wasm                      # ✅ WebAssembly binary files
│       └── index.html                  # ✅ Web application entry point
└── src/
    └── wasmJsMain/                     # ✅ Wasm/JS target source
        └── kotlin/
            └── com/kmm/frontend/
                ├── Main.kt             # ✅ Application entry point
                ├── App.kt              # ✅ Compose UI with Material3
                └── DataService.kt      # ✅ REST API service integration
```

**Frontend Module Contents:**
- ✅ **Main.kt**: Compose Canvas application entry point
- ✅ **App.kt**: Material3 UI with "Fetch Data" button and state management
- ✅ **DataService.kt**: REST API client using browser fetch API
- ✅ **WebAssembly Output**: Compiled Wasm bundles ready for browser
- ✅ **Development Server**: Webpack-based hot reload support

### ⚙️ Backend Module (`backend/`) ✅ **COMPLETE**

```
backend/
├── build.gradle.kts                    # ✅ Backend build config (pure JVM)
└── src/
    └── main/
        └── kotlin/
            └── com/kmm/backend/
                └── Server.kt           # ✅ Ktor server with REST API endpoints
```

**Backend Module Contents:**
- ✅ **Server.kt**: Ktor application with REST endpoints and content negotiation
- ✅ **JSON Serialization**: Automatic JSON conversion using Kotlinx Serialization
- ✅ **CORS Support**: Cross-origin request handling for frontend integration
- ✅ **Health Checks**: Monitoring and status endpoints
- ✅ **Shared Integration**: Uses data models from shared module

---

## Running the Application ✅ **FULLY OPERATIONAL**

### 🐳 Docker Setup (Recommended)

The easiest way to run the application is using Docker containers:

```bash
# Build and start both frontend and backend containers
docker-compose up --build -d

# View logs
docker-compose logs -f

# Stop containers
docker-compose down
```

**Services:**
- **Frontend**: http://localhost:8080 (Kotlin/Wasm + nginx)
- **Backend**: http://localhost:8081 (Kotlin/JVM + Ktor)

### 🔧 Local Development Setup

```bash
# Start everything (recommended)
./start.sh

# Stop everything
./stop.sh
```

### Manual Development Setup

1. **Start Backend Server:**
   ```bash
   ./gradlew :backend:run
   ```
   
   **Backend available at:**
   - Health check: http://localhost:8081/health
   - API endpoint: http://localhost:8081/api/dummy-data

2. **Start Frontend Development Server:**
   ```bash
   ./gradlew :frontend:wasmJsBrowserDevelopmentRun
   ```
   
   **Frontend available at:** http://localhost:8080

3. **Access the Application:**
   - Open `http://localhost:8080` in your browser
   - Click "Fetch Data" to test the REST API integration

### Build Commands

```bash
# Build everything
./gradlew build

# Clean and rebuild
./gradlew clean build

# Run backend only
./gradlew :backend:run

# Run frontend development server only
./gradlew :frontend:wasmJsBrowserDevelopmentRun
```

---

## Technology Stack & Versions

- **Kotlin**: 2.1.0 (latest stable)
- **Gradle**: 8.12 (latest stable) 
- **Compose Multiplatform**: 1.8.0+ (with Kotlin/Wasm support)
- **Ktor**: 3.0.3 ✅ **Working** (REST API server)
- **Kotlinx Serialization**: Latest stable ✅ **Working** (JSON serialization)
- **Material3**: Latest stable ✅ **Working** (UI design system)
- **Docker**: ✅ **Complete** (containerized deployment)
- **nginx**: Alpine ✅ **Working** (frontend web server)
- **Target**: Kotlin/Wasm (`wasm-js`) for frontend, JVM for backend

---

## Features

### 🎨 **Modern UI (Material3)**
- Beautiful Material3 design components
- Responsive layout with proper spacing
- Loading states and error handling
- Modern color scheme and typography

### 🔄 **REST API Integration**
- Type-safe communication using shared models
- Automatic JSON serialization/deserialization
- Error handling with user feedback
- CORS support for cross-origin requests

### 🛠️ **Developer Experience**
- Hot reload for frontend development
- Automated build scripts
- Health monitoring and logging
- Easy start/stop workflow

### 🚀 **Production Ready**
- Efficient WebAssembly compilation
- Optimized build pipeline
- Graceful server shutdown
- Configurable ports and settings

### 🐳 **Container Support**
- Multi-stage Docker builds for optimized images
- Production-ready nginx configuration
- Proper WASM MIME type handling
- Container orchestration with Docker Compose
- Health checks and container monitoring

---

## Development Workflow

### 🐳 **Container Development (Recommended)**
```bash
# Start containerized environment
docker-compose up --build -d

# View live logs
docker-compose logs -f

# Restart specific service
docker-compose restart frontend
docker-compose restart backend

# Stop containers
docker-compose down
```

### 🔧 **Local Development**
```bash
# Start development environment
./start.sh

# Make changes to code...
# Frontend automatically reloads
# Backend requires restart for changes

# Stop when done
./stop.sh
```

### 🧪 **Testing API**
```bash
# Test backend health
curl http://localhost:8081/health

# Test API endpoint
curl http://localhost:8081/api/dummy-data
```

### 📦 **Production Build**
```bash
# Docker production build (recommended)
docker-compose up --build -d

# Local production build
./gradlew build

# Frontend bundle: frontend/build/dist/wasmJs/productionExecutable/
# Backend JAR: backend/build/libs/backend.jar
```

### 🐳 **Docker Commands**
```bash
# Build images only
docker-compose build

# Start in foreground (see logs)
docker-compose up --build

# Check container status
docker-compose ps

# Access container shell
docker exec -it kmm-frontend sh
docker exec -it kmm-backend sh

# Clean up everything
docker-compose down --rmi all --volumes
```

---

## Stretch Goals & Future Enhancements

### 🔜 **Immediate Improvements**
- Add more REST endpoints (CRUD operations)
- Implement data validation and error responses
- Add loading animations and better UX

### 🚀 **Advanced Features**  
- Real-time updates with WebSockets
- User authentication and authorization
- Database integration (PostgreSQL/MongoDB)
- Docker containerization
- CI/CD pipeline setup

### 🏗️ **Architecture Enhancements**
- Microservices architecture
- API versioning and documentation
- Monitoring and metrics collection
- Performance optimization

---

## Contributing

### 📋 **Setup Requirements**
- Java 17+
- Gradle 8.12+
- Modern web browser with WebAssembly support

### 🔨 **Build Process**
1. Clone the repository
2. Run `./gradlew build` to verify setup
3. Use `./start.sh` to run development environment
4. Make changes and test
5. Run `./stop.sh` when done

### 🐛 **Common Issues**
- **Port conflicts**: Use `./stop.sh` to clean up processes
- **Build failures**: Try `./gradlew clean build`
- **CORS errors**: Ensure backend is running before frontend requests

---

## License

This project is a demonstration of Kotlin Multiplatform capabilities and is provided as-is for educational and development purposes.

---

**🎉 Ready to explore Kotlin Multiplatform with modern web technologies!**
