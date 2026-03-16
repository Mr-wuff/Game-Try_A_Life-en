import uvicorn
import logging
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(name)s: %(message)s")
logger = logging.getLogger("LifeSim")


def create_app() -> FastAPI:
    app = FastAPI(
        title="Infinite Life Simulator",
        description="LLM-powered life simulation game engine",
        version="4.1.0"
    )
    app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True,
                       allow_methods=["*"], allow_headers=["*"])

    @app.exception_handler(Exception)
    async def global_handler(request: Request, exc: Exception):
        logger.error(f"Unhandled exception: {exc}", exc_info=True)
        return JSONResponse(status_code=500, content={"error": "internal_server_error",
                                                       "detail": "An unexpected error occurred."})

    try:
        from api.routers import router as game_router
        app.include_router(game_router, prefix="/api", tags=["GameFlow"])
        logger.info("Game router loaded successfully")
    except ImportError as e:
        logger.warning(f"Router module not found: {e}")

    @app.get("/", tags=["System"])
    async def health():
        return {"status": "online", "message": "The engine of fate is running.", "version": "4.1.0"}

    return app


app = create_app()

if __name__ == "__main__":
    logger.info("Starting Infinite Life Simulator server...")
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)