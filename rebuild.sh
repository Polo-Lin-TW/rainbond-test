#!/bin/bash

echo "🔄 Rebuilding Hello World App..."

# Stop and remove existing container
echo "📋 Stopping existing container..."
docker stop hello-world-app 2>/dev/null || true
docker rm hello-world-app 2>/dev/null || true

# Build new image
echo "🏗️ Building Docker image..."
docker build -t hello-world-app .

if [ $? -eq 0 ]; then
    # Run new container
    echo "🚀 Starting new container..."
    docker run -d --name hello-world-app -p 8080:80 hello-world-app
    
    if [ $? -eq 0 ]; then
        echo "✅ Application successfully deployed!"
        echo "🌐 Application running at http://localhost:8080"
        echo "📊 API documentation: http://localhost:8080/docs"
        echo "🔍 Health check: http://localhost:8080/api/health"
        echo ""
        echo "📝 Useful commands:"
        echo "  docker logs hello-world-app          # View logs"
        echo "  docker logs -f hello-world-app       # Follow logs"
        echo "  docker stop hello-world-app          # Stop container"
    else
        echo "❌ Failed to start container!"
        exit 1
    fi
else
    echo "❌ Failed to build Docker image!"
    exit 1
fi