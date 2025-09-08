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

## Backend Codebase Analysis

### 專案架構概述
這是一個基於 FastAPI 的後端應用程式，採用 MVC 架構模式，提供 RESTful API 服務並支援前端靜態檔案服務。

### 檔案結構分析

#### 1. `backend/app/__init__.py`
- **用途**: Python 套件初始化檔案
- **內容**: 空檔案，將 `app` 目錄標記為 Python 套件
- **作用**: 允許其他模組透過 `from .database import ...` 方式匯入

#### 2. `backend/app/database.py`
**資料庫層 (Data Layer)**

**主要功能**:
- 資料庫連線設定
- ORM 模型定義
- 資料庫會話管理

**詳細分析**:
```python
# 資料庫配置
SQLITE_DATABASE_URL = "sqlite:///./app.db"
engine = create_engine(SQLITE_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
```

**Message 模型**:
- `id`: 主鍵，自動遞增
- `content`: 訊息內容，字串型態，建立索引
- `created_at`: 建立時間，預設為 UTC 時間

**核心函數**:
- `get_db()`: 資料庫會話依賴注入，使用 yield 確保連線正確關閉
- `create_tables()`: 建立資料庫表格

**設計模式**: 
- 使用 SQLAlchemy ORM
- 依賴注入模式 (Dependency Injection)
- 會話管理模式

#### 3. `backend/app/main.py`
**應用程式主檔案 (Application Layer)**

**主要功能**:
- FastAPI 應用程式初始化
- 路由定義
- 中介軟體配置
- 靜態檔案服務

**架構組件分析**:

**1. 應用程式配置**:
```python
app = FastAPI(title="Hello World API", version="1.0.0")
```

**2. CORS 中介軟體**:
- 允許來源: `localhost:8080`, `localhost:3000`
- 支援跨域請求，適用於前後端分離架構

**3. Pydantic 模型**:
- `MessageCreate`: 請求資料驗證
- `MessageResponse`: 回應資料序列化
- 使用 `from_attributes = True` 支援 ORM 物件轉換

**4. API 路由**:

| 路由 | 方法 | 功能 | 回應模型 |
|------|------|------|----------|
| `/index` | GET | 測試端點 | JSON |
| `/api/messages` | GET | 取得訊息列表 | List[MessageResponse] |
| `/api/messages` | POST | 建立新訊息 | MessageResponse |
| `/api/health` | GET | 健康檢查 | JSON |

**5. 靜態檔案服務**:
```python
# 條件式掛載靜態檔案
if os.path.exists("./static"):
    app.mount("/static", StaticFiles(directory="static"), name="static")
```

**6. SPA 路由處理**:
- 萬用路由 `/{full_path:path}` 處理前端路由
- 排除 API 路由避免衝突
- 實現 SPA 回退機制

### 技術棧分析

**核心技術**:
- **FastAPI**: 現代 Python Web 框架
- **SQLAlchemy**: ORM 資料庫操作
- **Pydantic**: 資料驗證和序列化
- **SQLite**: 輕量級資料庫

**設計模式**:
- **依賴注入**: 資料庫會話管理
- **Repository Pattern**: 透過 ORM 抽象資料存取
- **DTO Pattern**: 使用 Pydantic 模型分離內外部資料結構

**架構特點**:
- **前後端分離**: 支援 CORS 和靜態檔案服務
- **RESTful API**: 遵循 REST 設計原則
- **容器化部署**: 適配 Docker 環境
- **健康檢查**: 提供服務監控端點

### 資料流程

**讀取訊息流程**:
1. 客戶端請求 `GET /api/messages`
2. FastAPI 路由處理器接收請求
3. 透過依賴注入取得資料庫會話
4. 查詢最新 10 筆訊息，按時間倒序
5. SQLAlchemy 將 ORM 物件轉換為 Pydantic 模型
6. 回傳 JSON 格式資料

**建立訊息流程**:
1. 客戶端發送 `POST /api/messages` 請求
2. Pydantic 驗證請求資料
3. 建立新的 Message ORM 物件
4. 提交到資料庫並重新整理物件
5. 回傳建立的訊息資料

### 部署考量

**Docker 整合**:
- 靜態檔案從前端建置階段複製
- 支援環境變數配置
- 健康檢查機制

**擴展性**:
- 模組化設計便於功能擴展
- 資料庫抽象層支援不同資料庫
- 中介軟體架構支援功能插件

## Frontend Codebase Analysis

### 專案架構概述
這是一個基於 Vue.js 3 的現代前端應用程式，使用 Vite 作為建置工具，採用 SPA (Single Page Application) 架構，提供簡潔的使用者介面來與 FastAPI 後端進行互動。

### 檔案結構分析

#### 1. `frontend/index.html`
**應用程式入口點**

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Hello World App</title>
  </head>
  <body>
    <div id="app"></div>
    <script type="module" src="/src/main.js"></script>
  </body>
</html>
```

**特點**:
- 標準的 HTML5 結構
- 響應式設計的 viewport 設定
- 模組化 JavaScript 載入
- Vue.js 應用程式掛載點 `#app`

#### 2. `frontend/src/main.js`
**Vue 應用程式啟動檔案**

```javascript
import { createApp } from 'vue'
import App from './App.vue'

createApp(App).mount('#app')
```

**功能**:
- 使用 Vue 3 Composition API 的 `createApp`
- 匯入主要元件 `App.vue`
- 將應用程式掛載到 DOM 元素 `#app`

**設計模式**: 
- **單一職責**: 僅負責應用程式初始化
- **模組化**: 清晰的元件匯入結構

#### 3. `frontend/src/App.vue`
**主要應用程式元件**

**模板結構 (Template)**:
```vue
<template>
  <div id="app">
    <header>...</header>
    <main>
      <div class="card">API Status</div>
      <div class="card">Send Message</div>
      <div class="card">Recent Messages</div>
    </main>
  </div>
</template>
```

**元件架構**:
- **Header**: 應用程式標題和描述
- **API Status Card**: 顯示後端連線狀態
- **Send Message Card**: 訊息輸入表單
- **Recent Messages Card**: 訊息列表顯示

**腳本邏輯 (Script)**:

**資料狀態管理**:
```javascript
data() {
  return {
    apiStatus: '',      // API 連線狀態
    newMessage: '',     // 新訊息輸入
    messages: []        // 訊息列表
  }
}
```

**生命週期鉤子**:
```javascript
async mounted() {
  await this.checkHealth()    // 檢查 API 健康狀態
  await this.loadMessages()   // 載入訊息列表
}
```

**核心方法分析**:

1. **`checkHealth()`**: API 健康檢查
   - 使用 axios 發送 GET 請求到 `/api/health`
   - 錯誤處理和狀態顯示
   - 視覺化回饋 (✅/❌)

2. **`loadMessages()`**: 載入訊息列表
   - 從 `/api/messages` 取得資料
   - 錯誤處理和日誌記錄

3. **`sendMessage()`**: 發送新訊息
   - 輸入驗證 (`trim()` 檢查)
   - POST 請求到 `/api/messages`
   - 成功後清空輸入欄位並重新載入列表
   - 使用者友善的錯誤提示

4. **`formatDate()`**: 日期格式化
   - 將 ISO 日期字串轉換為本地化格式
   - 使用 `toLocaleString()` 提供使用者友善的時間顯示

**樣式設計 (Style)**:

**設計系統**:
- **色彩方案**: 漸層背景 (藍紫色調)
- **玻璃擬態設計**: 使用 `backdrop-filter: blur(10px)`
- **響應式設計**: 支援行動裝置
- **現代 UI**: 圓角、陰影、過渡效果

**CSS 架構**:
```css
/* 全域重置 */
* { margin: 0; padding: 0; box-sizing: border-box; }

/* 主要佈局 */
#app { max-width: 800px; margin: 0 auto; }

/* 卡片元件 */
.card { 
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border-radius: 15px;
}
```

**互動設計**:
- 按鈕懸停效果 (`transform: translateY(-2px)`)
- 輸入框焦點狀態
- 禁用狀態處理
- 平滑過渡動畫

#### 4. `frontend/package.json`
**專案配置和依賴管理**

**專案資訊**:
- 名稱: `rainbond-frontend`
- 版本: `1.0.0`
- 描述: Vue.js frontend for Hello World app

**腳本命令**:
- `dev`: 開發伺服器 (Vite)
- `build`: 生產建置
- `preview`: 預覽建置結果

**依賴分析**:

**生產依賴**:
- `vue@^3.3.8`: Vue.js 3 核心框架
- `axios@^1.6.0`: HTTP 客戶端庫

**開發依賴**:
- `@vitejs/plugin-vue@^4.4.0`: Vite Vue 插件
- `vite@^4.5.0`: 現代建置工具

#### 5. `frontend/vite.config.js`
**建置工具配置**

```javascript
export default defineConfig({
  plugins: [vue()],           // Vue 支援
  base: '/',                  // 基礎路徑
  build: {
    outDir: 'dist',          // 輸出目錄
    assetsDir: 'assets',     // 資源目錄
  },
  server: {
    port: 8080,              // 開發伺服器端口
    proxy: {                 // API 代理設定
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true
      }
    }
  }
})
```

**配置特點**:
- **開發代理**: 解決 CORS 問題
- **建置優化**: 清晰的輸出結構
- **插件系統**: Vue SFC 支援

### 技術棧分析

**核心技術**:
- **Vue.js 3**: 漸進式 JavaScript 框架
- **Vite**: 快速建置工具
- **Axios**: Promise 基礎的 HTTP 庫
- **ES6+ Modules**: 現代 JavaScript 模組系統

**開發工具**:
- **Hot Module Replacement (HMR)**: 開發時熱更新
- **TypeScript 支援**: 透過 Vite 插件
- **CSS 預處理**: 內建支援

**設計模式**:
- **單檔案元件 (SFC)**: Vue 的核心開發模式
- **響應式資料**: Vue 3 響應式系統
- **組合式 API**: 現代 Vue 開發方式 (雖然此專案使用 Options API)

### 使用者體驗設計

**互動流程**:
1. **頁面載入**: 自動檢查 API 狀態和載入訊息
2. **健康檢查**: 即時顯示後端連線狀態
3. **訊息發送**: 支援 Enter 鍵快速發送
4. **即時更新**: 發送後自動重新載入列表
5. **錯誤處理**: 友善的錯誤訊息提示

**可用性特點**:
- **響應式設計**: 適配不同螢幕尺寸
- **鍵盤支援**: Enter 鍵發送訊息
- **視覺回饋**: 按鈕狀態、載入指示
- **無障礙設計**: 語意化 HTML 結構

### 資料流程

**應用程式初始化**:
1. Vue 應用程式掛載
2. 執行 `mounted()` 生命週期
3. 並行執行健康檢查和訊息載入
4. 更新 UI 狀態

**訊息發送流程**:
1. 使用者輸入訊息
2. 前端驗證 (非空檢查)
3. 發送 POST 請求到後端
4. 成功後清空輸入欄位
5. 重新載入訊息列表
6. 更新 UI 顯示

**錯誤處理機制**:
- **網路錯誤**: 顯示連線失敗訊息
- **API 錯誤**: 控制台日誌記錄
- **使用者錯誤**: 輸入驗證和提示

### 效能考量

**建置優化**:
- **Vite 建置**: 快速的開發和生產建置
- **Tree Shaking**: 自動移除未使用的程式碼
- **資源分割**: CSS 和 JS 檔案分離

**執行時優化**:
- **響應式更新**: Vue 3 高效的響應式系統
- **事件處理**: 適當的事件綁定和解綁
- **記憶體管理**: 元件銷毀時自動清理

### 擴展性設計

**元件化潛力**:
- 可將卡片抽取為獨立元件
- 訊息項目可獨立為 MessageItem 元件
- 表單可抽取為 MessageForm 元件

**功能擴展**:
- 路由系統 (Vue Router)
- 狀態管理 (Pinia/Vuex)
- 國際化支援 (Vue I18n)
- 測試框架 (Vitest/Jest)