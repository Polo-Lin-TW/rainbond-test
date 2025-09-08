# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A full-stack Hello World web application demonstrating FastAPI + Vue.js + SQLite integration.

### Architecture

- **Backend**: FastAPI with SQLite database using SQLAlchemy ORM
- **Frontend**: Vue.js 3 with Vite build tool
- **Database**: SQLite with message storage capability
- **Deployment**: Docker multi-stage build

### Project Structure

```
rainbond-test/
├── backend/           # FastAPI backend
│   ├── app/
│   │   ├── main.py    # FastAPI app with API endpoints
│   │   └── database.py # SQLAlchemy models and database config
│   └── requirements.txt
├── frontend/          # Vue.js frontend
│   ├── src/
│   │   ├── App.vue    # Main Vue component
│   │   └── main.js    # Vue app entry point
│   ├── package.json
│   └── vite.config.js
└── Dockerfile         # Multi-stage build for production
```

## Development Commands

### Backend Development

```bash
cd backend
source .venv/bin/activate  # or create new venv if needed
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

### Frontend Development

```bash
cd frontend
npm install
npm run dev  # Runs on port 8080
```

### Full Stack Development

Run both simultaneously:
- Backend: `uvicorn app.main:app --reload --port 8000`
- Frontend: `npm run dev` (in frontend directory)

### Docker Development

```bash
# Clean up previous builds (if needed)
docker stop hello-world-app 2>/dev/null || true
docker rm hello-world-app 2>/dev/null || true
docker rmi hello-world-app 2>/dev/null || true

# Build Docker image (run from project root)
cd /home/ubuntu/rainbond-test  # or your project root
docker build -t hello-world-app .

# Run container
docker run -d --name hello-world-app -p 8080:80 hello-world-app

# Monitor container
docker ps
docker logs hello-world-app
docker logs -f hello-world-app  # Follow logs

# Stop and remove container
docker stop hello-world-app
docker rm hello-world-app
```

### Production Build

```bash
# Frontend build only (for manual deployment)
cd frontend && npm run build

# Full Docker production build
docker build -t hello-world-app .
docker run -p 8080:80 hello-world-app
```

## API Endpoints

- `GET /` - Welcome message
- `GET /api/health` - Health check
- `GET /api/messages` - Get messages
- `POST /api/messages` - Create message

## Database

SQLite database with Messages table:
- `id` (Primary key)
- `content` (String)
- `created_at` (DateTime)

Database auto-created on startup via SQLAlchemy.

## Key Technologies

- **FastAPI**: Modern Python web framework
- **Vue.js 3**: Progressive frontend framework
- **Vite**: Fast build tool for Vue.js
- **SQLAlchemy**: Python SQL toolkit and ORM
- **SQLite**: Lightweight database
- **Docker**: Containerization

## Development Notes

- CORS configured for frontend-backend communication
- Proxy setup in Vite config for API calls
- Responsive design with gradient styling
- Health check endpoint for monitoring
- Static file serving in production via FastAPI

## Docker Troubleshooting

### Common Docker Issues

1. **Build from wrong directory**: Always run `docker build` from project root, not backend/frontend subdirectories
2. **Port conflicts**: Ensure port 8080 is not in use by other services
3. **Container not starting**: Check logs with `docker logs hello-world-app`
4. **Frontend not loading**: Verify static files are properly copied to `/app/static` in container
5. **API not accessible**: Ensure FastAPI is serving on `0.0.0.0:80` inside container

### Docker Commands Reference

```bash
# Development cycle
docker build -t hello-world-app .                    # Build image
docker run -d --name hello-world-app -p 8080:80 hello-world-app  # Run detached
docker ps                                            # List running containers
docker logs hello-world-app                          # View logs
docker exec -it hello-world-app /bin/bash           # Enter container shell
docker stop hello-world-app                         # Stop container
docker rm hello-world-app                           # Remove container
docker rmi hello-world-app                          # Remove image

# Debugging
docker inspect hello-world-app                      # Container details
docker exec hello-world-app ls -la /app/static      # Check static files
docker exec hello-world-app ps aux                  # Check processes
```

### Container Structure

- **Working directory**: `/app`
- **Static files**: `/app/static` (Vue.js build output)
- **Database**: `/app/data/app.db` (SQLite)
- **Backend code**: `/app/app/` (FastAPI application)
- **Port**: Container listens on port 80, mapped to host 8080