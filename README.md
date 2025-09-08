# Hello World Web App

A simple full-stack web application demonstrating the integration of FastAPI backend, Vue.js frontend, and SQLite database.

## Features

- **Backend**: FastAPI with SQLite database
- **Frontend**: Vue.js 3 with Vite
- **Database**: SQLite with SQLAlchemy ORM
- **API**: RESTful endpoints for message management
- **Real-time**: Message posting and retrieval
- **Responsive**: Mobile-friendly design

## Project Structure

```
rainbond-test/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py          # FastAPI application
│   │   └── database.py      # Database models and configuration
│   └── requirements.txt     # Python dependencies
├── frontend/
│   ├── src/
│   │   ├── App.vue         # Main Vue component
│   │   └── main.js         # Vue application entry point
│   ├── index.html          # HTML template
│   ├── package.json        # Node.js dependencies
│   └── vite.config.js      # Vite configuration
├── Dockerfile              # Docker configuration
├── README.md              # This file
└── CLAUDE.md              # Claude Code guidance
```

## Prerequisites

- Python 3.10+
- Node.js 16+
- npm or yarn
- Docker (optional, for containerized deployment)

## Development Setup

### Backend Setup

1. Navigate to the backend directory:
```bash
cd backend
```

2. Create and activate virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Run the FastAPI server:
```bash
uvicorn app.main:app --reload --port 8000
```

The API will be available at `http://localhost:8000`
- API documentation: `http://localhost:8000/docs`
- Alternative docs: `http://localhost:8000/redoc`

### Frontend Setup

1. Navigate to the frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
npm install
```

3. Start the development server:
```bash
npm run dev
```

The frontend will be available at `http://localhost:8080`

### Full Stack Development

To run both backend and frontend simultaneously:

1. Terminal 1 - Backend:
```bash
cd backend
source venv/bin/activate
uvicorn app.main:app --reload --port 8000
```

2. Terminal 2 - Frontend:
```bash
cd frontend
npm run dev
```

## API Endpoints

### Base URL: `http://localhost:8000`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Welcome message |
| GET | `/api/health` | Health check |
| GET | `/api/messages` | Get recent messages |
| POST | `/api/messages` | Create new message |

### Example API Usage

**Get messages:**
```bash
curl http://localhost:8000/api/messages
```

**Create message:**
```bash
curl -X POST "http://localhost:8000/api/messages" \
     -H "Content-Type: application/json" \
     -d '{"content": "Hello World!"}'
```

## Database

The application uses SQLite database (`app.db`) with the following schema:

### Messages Table
- `id`: Primary key (Integer)
- `content`: Message content (String)
- `created_at`: Timestamp (DateTime)

The database file will be automatically created when the backend starts.

## Docker Deployment

### Quick Start with Docker

⚠️ **Important**: Always run Docker commands from the project root directory (`/home/ubuntu/rainbond-test`), not from backend or frontend subdirectories.

```bash
# Navigate to project root
cd /home/ubuntu/rainbond-test

# Clean up any existing containers/images (optional)
docker stop hello-world-app 2>/dev/null || true
docker rm hello-world-app 2>/dev/null || true
docker rmi hello-world-app 2>/dev/null || true

# Build the image
docker build -t hello-world-app .

# Run the container (detached mode)
docker run -d --name hello-world-app -p 8080:80 hello-world-app
```

The application will be available at `http://localhost:8080`

### Docker Management Commands

```bash
# Check container status
docker ps                              # List running containers
docker ps -a                           # List all containers

# View logs
docker logs hello-world-app            # View container logs
docker logs -f hello-world-app         # Follow logs in real-time

# Container operations
docker stop hello-world-app            # Stop the container
docker start hello-world-app           # Start stopped container
docker restart hello-world-app         # Restart container
docker rm hello-world-app              # Remove container
docker rmi hello-world-app              # Remove image

# Debug inside container
docker exec -it hello-world-app /bin/bash  # Enter container shell
docker exec hello-world-app ls -la /app/static  # Check static files
```

### Docker Troubleshooting

**Common Issues:**

1. **"failed to read dockerfile" error**: 
   - Make sure you're in the project root directory
   - Run `pwd` to verify you're in `/home/ubuntu/rainbond-test`

2. **Port already in use**: 
   ```bash
   # Find process using port 8080
   sudo lsof -i :8080
   # Or use different port
   docker run -d --name hello-world-app -p 8081:80 hello-world-app
   ```

3. **Frontend not loading**:
   ```bash
   # Check if static files exist in container
   docker exec hello-world-app ls -la /app/static
   # Check container logs for errors
   docker logs hello-world-app
   ```

4. **API not responding**:
   ```bash
   # Test health endpoint
   curl http://localhost:8080/api/health
   # Check if FastAPI is running inside container
   docker exec hello-world-app ps aux | grep uvicorn
   ```

## Production Deployment

### Backend Production

```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### Frontend Production

```bash
cd frontend
npm install
npm run build
```

Serve the `dist/` directory with any static file server.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DATABASE_URL` | `sqlite:///./app.db` | Database connection string |
| `FRONTEND_URL` | `http://localhost:8080` | Frontend URL for CORS |

## Troubleshooting

### Common Issues

1. **CORS Error**: Ensure the frontend URL is included in the FastAPI CORS middleware
2. **Database Connection**: Check if the SQLite database file has proper permissions
3. **Port Conflicts**: Make sure ports 8000 (backend) and 8080 (frontend) are available

### Development Tips

- Backend API documentation is available at `/docs`
- Use browser developer tools to debug frontend issues
- Check backend logs for API errors
- Database will be recreated if deleted (no data persistence in development)

### Docker Development Workflow

1. **Development cycle**:
   ```bash
   # Make code changes
   # Rebuild image
   docker build -t hello-world-app .
   # Stop old container
   docker stop hello-world-app && docker rm hello-world-app
   # Start new container
   docker run -d --name hello-world-app -p 8080:80 hello-world-app
   ```

2. **Quick rebuild script** (save as `rebuild.sh`):
   ```bash
   #!/bin/bash
   docker stop hello-world-app 2>/dev/null || true
   docker rm hello-world-app 2>/dev/null || true
   docker build -t hello-world-app .
   docker run -d --name hello-world-app -p 8080:80 hello-world-app
   echo "Application running at http://localhost:8080"
   ```

3. **Container information**:
   - **Working directory**: `/app`
   - **Static files**: `/app/static` (Vue.js build)
   - **Database**: `/app/data/app.db` (SQLite)
   - **Logs**: Access via `docker logs hello-world-app`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is open source and available under the MIT License.