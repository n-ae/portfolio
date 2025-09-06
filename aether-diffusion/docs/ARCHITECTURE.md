# Multi-Layer Multi-Language Architecture

## Overview

This project implements a comprehensive Yahoo Fantasy Sports API integration using a layered architecture approach with implementations in both Zig and Go. The architecture consists of three main layers that depend on each other in a clear hierarchy.

## Architecture Layers

### Layer 1: SDK (Software Development Kit)
- **Purpose**: Core API bindings and business logic for Yahoo Fantasy Sports API
- **Dependencies**: External Yahoo Fantasy API only
- **Implementations**: 
  - `zig/sdk/` - Zig implementation
  - `go/sdk/` - Go implementation

**Responsibilities:**
- OAuth 1.0 authentication
- Rate limiting and retry logic
- API request/response handling
- Data models and serialization
- Error handling and logging
- Caching layer

### Layer 2: Web API (HTTP API Server)
- **Purpose**: RESTful HTTP API that exposes SDK functionality
- **Dependencies**: SDK layer
- **Implementations**:
  - `zig/webapi/` - Zig HTTP server using zap framework
  - `go/webapi/` - Go HTTP server using standard library/gorilla mux

**Responsibilities:**
- HTTP route handling
- Request validation and transformation
- Authentication middleware
- Rate limiting middleware
- CORS handling
- Health checks and metrics
- Swagger/OpenAPI documentation

### Layer 3: Web Client (Frontend Application)
- **Purpose**: User-facing web application that consumes the Web API
- **Dependencies**: Web API layer via HTTP
- **Implementations**:
  - `zig/webclient/` - Server-side rendered HTML with HTMX
  - `go/webclient/` - Server-side rendered HTML with htmx

**Responsibilities:**
- User interface and user experience
- HTML templating and rendering
- Client-side interactivity
- Form handling and validation
- Session management
- Progressive enhancement

## Dependency Flow

```
Web Client → Web API → SDK → Yahoo Fantasy API
```

Each layer only depends on the layer directly below it, ensuring:
- Clear separation of concerns
- Independent testing capabilities
- Modular deployment options
- Language-agnostic interfaces

## Cross-Cutting Concerns

### Testing (`scripts/`)
- **Correctness Tests**: End-to-end API contract validation
- **Performance Tests**: Load testing and benchmarking across languages
- **Integration Tests**: Cross-layer validation

### Build and Deployment
- Language-specific build processes
- Docker containerization
- Infrastructure as Code (Terraform)
- CI/CD pipeline automation

## Language Implementation Goals

### Zig Implementation
- **Focus**: Performance, memory safety, and minimal dependencies
- **Strengths**: Zero-cost abstractions, compile-time safety, small binaries
- **Use Cases**: High-performance scenarios, embedded systems, systems programming

### Go Implementation
- **Focus**: Developer productivity, ecosystem, and maintainability
- **Strengths**: Rich ecosystem, excellent tooling, built-in concurrency
- **Use Cases**: Rapid development, microservices, cloud-native applications

## Data Flow

1. **User Request**: Web Client receives user interaction
2. **API Call**: Web Client makes HTTP request to Web API
3. **Business Logic**: Web API calls SDK for data processing
4. **External API**: SDK communicates with Yahoo Fantasy API
5. **Response Chain**: Data flows back through each layer
6. **User Interface**: Web Client renders response to user

## Quality Assurance

### Cross-Language Testing
- Identical test scenarios across both implementations
- Performance benchmarking and comparison
- API contract validation
- End-to-end integration testing

### Monitoring and Observability
- Health checks at each layer
- Metrics collection and reporting
- Distributed tracing capabilities
- Error tracking and alerting

## Deployment Strategies

### Monolithic Deployment
- All layers deployed together
- Simplified operations
- Reduced network latency

### Microservices Deployment
- Each layer deployed independently
- Horizontal scaling capabilities
- Technology stack flexibility
- Fault isolation

### Hybrid Deployment
- SDK as shared library
- Web API as microservice
- Web Client as separate frontend application