from fastapi import FastAPI
import uvicorn

app = FastAPI(title="NanoPi FM350 Manager")

@app.get("/api/health")
async def health():
    return {"status": "ok", "modem": "FM350-GL (mock)"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8080)
