# Multi-stage build for production deployment
FROM node:18-alpine AS frontend-builder

# 設置 npm 鏡像源以加速安裝（可選）
RUN npm config set registry https://registry.npmmirror.com/

# Build frontend
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci --only=production
COPY frontend/ ./
RUN npm run build

# Python backend stage - 使用 Rainbond 支援的 Python 3.9.16 版本
FROM python:3.9.16-slim

# 設置環境變數防止 Python 生成 .pyc 檔案和緩衝輸出
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# 設置工作目錄
WORKDIR /app

# 建立非 root 使用者以提升安全性
RUN groupadd -r appuser && useradd -r -g appuser appuser

# 安裝系統相依性
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    make \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# 升級 pip 到最新版本以解決 Rainbond pip 9.0.2 錯誤
RUN pip install --upgrade pip setuptools wheel

# 複製並安裝 Python 相依性
COPY requirements.txt ./

# 安裝 Python 套件，使用較新的 pip
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# 建立必要目錄並設置權限
RUN mkdir -p /app/data /app/logs /app/static \
    && chown -R appuser:appuser /app

# 複製後端程式碼
COPY --chown=appuser:appuser backend/ ./

# 從前端建置階段複製靜態檔案
COPY --from=frontend-builder --chown=appuser:appuser /app/frontend/dist ./static

# 切換到非 root 使用者
USER appuser

# 暴露埠號
EXPOSE 80

# 環境變數
ENV DATABASE_URL=sqlite:///./data/app.db \
    PYTHONPATH=/app \
    UVICORN_HOST=0.0.0.0 \
    UVICORN_PORT=80

# 健康檢查 - 改用內建方式避免外部相依性
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:80/api/health', timeout=5)" || exit 1

# 啟動應用程式
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]