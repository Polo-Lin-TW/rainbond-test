# 問題記錄與解決方案

## Issue #1: Backend API /api/messages 連線異常

### 問題描述

執行 `curl -X 'GET' 'http://localhost:8000/api/messages' -H 'accept: application/json'` 時出現 Internal Server Error。

**錯誤訊息:**
```
Error: Internal Server Error
Response body: Internal Server Error
Response headers:
 content-length: 21 
 content-type: text/plain; charset=utf-8 
 date: Tue,09 Sep 2025 04:58:32 GMT 
 server: uvicorn
```

### 詳細錯誤分析

**伺服器日誌顯示的完整錯誤:**
```
ERROR: Exception in ASGI application
Traceback (most recent call last):
  ...
  File "/home/ubuntu/rainbond-test/.venv/lib/python3.9/site-packages/fastapi/routing.py", line 155, in serialize_response
    raise ResponseValidationError(
fastapi.exceptions.ResponseValidationError: 10 validation errors:
  {'loc': ('response', 0), 'msg': 'value is not a valid dict', 'type': 'type_error.dict'}
  {'loc': ('response', 1), 'msg': 'value is not a valid dict', 'type': 'type_error.dict'}
  ...
  {'loc': ('response', 9), 'msg': 'value is not a valid dict', 'type': 'type_error.dict'}
```

### 根本原因

**Pydantic 版本配置不匹配:**
- 系統使用 Pydantic v1.10.22
- 但在 `MessageResponse` 模型中使用了 Pydantic v2 的語法 `from_attributes = True`
- Pydantic v1 應該使用 `orm_mode = True`

**技術說明:**
- SQLAlchemy ORM 返回物件實例，需要透過 Pydantic 配置轉換為字典格式
- `orm_mode = True` 告訴 Pydantic v1 如何處理 ORM 物件
- `from_attributes = True` 是 Pydantic v2 的新語法

### 解決方案

**修改檔案:** `/home/ubuntu/rainbond-test/backend/app/main.py`

**修改內容:**
```python
# 修改前 (錯誤配置)
class MessageResponse(BaseModel):
    id: int
    content: str
    created_at: datetime
    
    class Config:
        from_attributes = True  # Pydantic v2 語法

# 修改後 (正確配置)
class MessageResponse(BaseModel):
    id: int
    content: str
    created_at: datetime
    
    class Config:
        orm_mode = True  # Pydantic v1 語法
```

### 驗證結果

**測試命令與結果:**

1. **GET /api/messages** - 獲取消息列表
```bash
curl -X 'GET' 'http://localhost:8000/api/messages' -H 'accept: application/json'
```
**成功回應:**
```json
[
  {
    "id": 10,
    "content": "123",
    "created_at": "2025-09-09T04:57:56.800679"
  },
  ...
]
```

2. **GET /api/health** - 健康檢查
```bash
curl -X 'GET' 'http://localhost:8000/api/health' -H 'accept: application/json'
```
**成功回應:**
```json
{
  "status": "healthy",
  "message": "Service is running"
}
```

3. **POST /api/messages** - 創建新消息
```bash
curl -X 'POST' 'http://localhost:8000/api/messages' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{"content":"Test message from curl"}'
```
**成功回應:**
```json
{
  "id": 11,
  "content": "Test message from curl",
  "created_at": "2025-09-09T05:03:30.464136"
}
```

### 預防措施

1. **版本檢查:** 確認 Pydantic 版本並使用對應語法
   ```bash
   pip show pydantic
   ```

2. **配置對照表:**
   | Pydantic 版本 | ORM 模式配置 |
   |--------------|-------------|
   | v1.x | `orm_mode = True` |
   | v2.x | `from_attributes = True` |

3. **開發建議:**
   - 建立 API 端點後立即進行功能測試
   - 檢查伺服器日誌以獲取詳細錯誤資訊
   - 使用版本鎖定避免依賴衝突

### 相關技術

- **FastAPI**: 現代 Python web 框架
- **Pydantic**: 資料驗證和序列化
- **SQLAlchemy**: ORM 資料庫操作
- **Uvicorn**: ASGI 伺服器

### 解決日期
2025-09-09

### 狀態
✅ 已解決