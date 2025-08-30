# Container Deployment

This directory contains all containerization assets for the Yahoo Fantasy API Zig wrapper.

## Quick Start

```bash
# Development (fast build, requires local Zig installation)
./container/build-simple.sh
docker run -p 8080:8080 -e YAHOO_CONSUMER_KEY=demo -e YAHOO_CONSUMER_SECRET=demo yahoo-fantasy-api

# Production (self-contained build, takes longer)
./container/build.sh
docker run -p 8080:8080 --env-file .env yahoo-fantasy-api
```

## Files Overview

### Container Definitions
- **`Containerfile`** - Production multi-stage build (builds Zig from source)
- **`Containerfile.simple`** - Development build (uses pre-built binary)

### Build Scripts
- **`build.sh`** - Production container build (full multi-stage)
- **`build-simple.sh`** - Development container build (cross-compile + copy)
- **`test.sh`** - Step-by-step build testing

### Orchestration
- **`docker-compose.yml`** - Complete service orchestration

## Build Options

### Option 1: Development Build (Recommended)
**Fast builds using local cross-compilation**

```bash
# Build (30 seconds)
./container/build-simple.sh

# Run
docker run -d -p 8080:8080 \
  -e YAHOO_CONSUMER_KEY=your_key \
  -e YAHOO_CONSUMER_SECRET=your_secret \
  --name yahoo-fantasy-api \
  yahoo-fantasy-api:latest
```

**Requirements:** Local Zig 0.15.1+ installation

### Option 2: Production Build
**Self-contained builds with Zig compilation in container**

```bash
# Build (5-10 minutes first time)
./container/build.sh

# Run
docker run -d -p 8080:8080 --env-file .env yahoo-fantasy-api:latest
```

**Requirements:** None (downloads and builds Zig in container)

### Option 3: Docker Compose
**Complete orchestration with networking and health checks**

```bash
# Build and run
docker-compose -f container/docker-compose.yml up -d

# Check status
docker-compose -f container/docker-compose.yml ps

# View logs
docker-compose -f container/docker-compose.yml logs
```

## Configuration

### Environment Variables
| Variable | Description | Required |
|----------|-------------|----------|
| `YAHOO_CONSUMER_KEY` | Yahoo API consumer key | Yes |
| `YAHOO_CONSUMER_SECRET` | Yahoo API consumer secret | Yes |
| `YAHOO_ACCESS_TOKEN` | User access token | No |
| `YAHOO_ACCESS_TOKEN_SECRET` | User access token secret | No |
| `PORT` | Server port (default: 8080) | No |

### Using .env File
```bash
# Copy template
cp .env.example .env

# Edit with your credentials
YAHOO_CONSUMER_KEY=your_actual_key
YAHOO_CONSUMER_SECRET=your_actual_secret

# Run with .env
docker run -d -p 8080:8080 --env-file .env yahoo-fantasy-api
```

## Testing

### Health Checks
```bash
# Basic health check
curl http://localhost:8080/health

# API status
curl http://localhost:8080/status

# Demo data parsing
curl http://localhost:8080/demo
```

### Container Health
```bash
# Check container status
docker ps

# View logs
docker logs yahoo-fantasy-api

# Container stats
docker stats yahoo-fantasy-api
```

## Architecture Support

The containers support multiple architectures:

- **linux/amd64** - Intel/AMD 64-bit (default)
- **linux/arm64** - ARM 64-bit (Apple Silicon, AWS Graviton)

```bash
# Build for specific platform
PLATFORM=linux/arm64 ./container/build.sh

# Multi-platform build
docker buildx build --platform linux/amd64,linux/arm64 -f container/Containerfile .
```

## Registry Deployment

### Tagging for Registry
```bash
# Build with registry tag
REGISTRY=your-registry.com TAG=v1.0.0 ./container/build.sh

# Push to registry
docker push your-registry.com/yahoo-fantasy-api:v1.0.0
```

### Kubernetes Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: yahoo-fantasy-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: yahoo-fantasy-api
  template:
    metadata:
      labels:
        app: yahoo-fantasy-api
    spec:
      containers:
      - name: yahoo-fantasy-api
        image: yahoo-fantasy-api:latest
        ports:
        - containerPort: 8080
        env:
        - name: YAHOO_CONSUMER_KEY
          valueFrom:
            secretKeyRef:
              name: yahoo-api-secrets
              key: consumer-key
        - name: YAHOO_CONSUMER_SECRET
          valueFrom:
            secretKeyRef:
              name: yahoo-api-secrets
              key: consumer-secret
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /health
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 10
```

## Troubleshooting

### Common Issues

1. **"Exec format error"**
   - Cause: Architecture mismatch (ARM binary on AMD64 or vice versa)
   - Solution: Use cross-compilation with `-Dtarget=x86_64-linux`

2. **Container exits immediately**
   - Cause: Missing required environment variables
   - Solution: Set `YAHOO_CONSUMER_KEY` and `YAHOO_CONSUMER_SECRET`

3. **Build takes too long**
   - Cause: Full Zig compilation in container
   - Solution: Use `build-simple.sh` for development

4. **Port conflicts**
   - Cause: Port 8080 already in use
   - Solution: Use different port `-p 8081:8080`

### Debug Commands
```bash
# Interactive shell in container
docker run -it --entrypoint=/bin/sh yahoo-fantasy-api

# Check container filesystem
docker run --rm -it yahoo-fantasy-api ls -la /app

# View container environment
docker run --rm yahoo-fantasy-api env
```

## Cloud Deployment

### Google Cloud Run (Recommended - FREE!)
**Best for 1000 requests/month - stays within free tier**

```bash
# Deploy to Cloud Run (completely free for your usage!)
./container/deploy-cloudrun.sh deploy

# Test deployment
./container/deploy-cloudrun.sh test
```

**Cost Analysis:**
- ✅ **$0/month** for up to 2M requests (you need 1K)
- ✅ Automatic scaling to zero
- ✅ Built-in HTTPS and CDN
- ✅ No server management

See [`deploy-cloudrun.sh`](deploy-cloudrun.sh) for complete Cloud Run deployment.

### Other Cloud Options

| Provider | Monthly Cost | Free Tier | Best For |
|----------|-------------|-----------|----------|
| **Google Cloud Run** | **$0** | 2M requests | ⭐ **Recommended** |
| Oracle Cloud | $0 | Always free | Alternative |
| Azure Container Apps | $0-1 | $200 credit | Microsoft ecosystem |
| Fly.io | $0-5 | Limited | Modern platform |
| Railway | $0-5 | $5 credit | Simple deploy |
| Vultr | $2.50 | None | Traditional VPS |

## Performance

### Resource Usage
- **CPU**: ~5-10% idle, ~20-50% under load
- **Memory**: ~10-20MB base, ~50-100MB under load
- **Container Size**: ~30MB (simple), ~200MB (full build)

### Scaling
```bash
# Docker Swarm
docker service create \
  --name yahoo-fantasy-api \
  --replicas 3 \
  --publish 8080:8080 \
  --env-file .env \
  yahoo-fantasy-api:latest

# Update service
docker service update --image yahoo-fantasy-api:v1.1.0 yahoo-fantasy-api
```