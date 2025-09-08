from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import List
from datetime import datetime
import os

from .database import get_db, create_tables, Message

app = FastAPI(title="Hello World API", version="1.0.0")

# CORS middleware for Vue.js frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:8080", "http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class MessageCreate(BaseModel):
    content: str


class MessageResponse(BaseModel):
    id: int
    content: str
    created_at: datetime
    
    class Config:
        from_attributes = True


@app.on_event("startup")
async def startup_event():
    create_tables()


@app.get("/")
async def root():
    # print("Hello World from FastAPI!")
    return {"message": "Hello World from FastAPI!"}


@app.get("/api/messages", response_model=List[MessageResponse])
async def get_messages(db: Session = Depends(get_db)):
    messages = db.query(Message).order_by(Message.created_at.desc()).limit(10).all()
    return messages


@app.post("/api/messages", response_model=MessageResponse)
async def create_message(message: MessageCreate, db: Session = Depends(get_db)):
    db_message = Message(content=message.content)
    db.add(db_message)
    db.commit()
    db.refresh(db_message)
    return db_message


@app.get("/api/health")
async def health_check():
    return {"status": "healthy", "message": "Service is running"}


# Serve static files (for Docker deployment)
if os.path.exists("./static"):
    app.mount("/static", StaticFiles(directory="static"), name="static")
    
    # Serve index.html for SPA routing
    
    @app.get("/{full_path:path}")
    async def serve_spa(full_path: str):
        # Don't serve SPA for API routes
        if full_path.startswith("api/") or full_path.startswith("docs") or full_path.startswith("redoc"):
            raise HTTPException(status_code=404, detail="Not found")
        
        # Check if it's a static file request
        static_file_path = f"./static/{full_path}"
        if os.path.exists(static_file_path) and os.path.isfile(static_file_path):
            return FileResponse(static_file_path)
        
        # Serve index.html for SPA routes
        index_file = "./static/index.html"
        if os.path.exists(index_file):
            return FileResponse(index_file)
        
        raise HTTPException(status_code=404, detail="Not found")