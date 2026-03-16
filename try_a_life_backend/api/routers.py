import os
import logging
from fastapi import APIRouter, HTTPException
from typing import Dict, Any

from .schemas import StartGameRequest, NormalChoiceRequest, NodeChoiceRequest
from core.game_session import GameSession
from core.event_resolver import EventResolver
from world_data.config_loader import load_world_config
from llm.ollama_client import OllamaBackend
from systems.inventory_sys import InventorySystem
from systems.achievement_sys import AchievementSystem
from llm.model_manager import (
    check_ollama_running, list_installed_models, get_model_catalog,
    start_pull, get_pull_progress, RECOMMENDED_MODELS,
)
from llm.openai_client import OpenAIBackend

logger = logging.getLogger("LifeSimulator.API")
router = APIRouter()

class SessionManager:
    def __init__(self):
        self.session = None
        
        installed_models = list_installed_models()
        default_model = os.environ.get("ILS_MODEL", "llama3.1:8b")
        
        if default_model not in installed_models and len(installed_models) > 0:
            default_model = installed_models[0]
            logger.info(f"Default model not found. Auto-switched to available local model: {default_model}")
            
        self.llm_backend = OllamaBackend(model_name=default_model)
        self.current_provider = "ollama"

    def switch_model(self, model_id: str):
        self.llm_backend = OllamaBackend(model_name=model_id)
        self.current_provider = "ollama"
        logger.info(f"Switched LLM model to local Ollama: {model_id}")

    def switch_to_custom_api(self, api_url: str, api_key: str, model_name: str):
        self.llm_backend = OpenAIBackend(api_key=api_key, base_url=api_url, model_name=model_name)
        self.current_provider = "custom"
        logger.info(f"Switched LLM to Custom API: {model_name} at {api_url}")

manager = SessionManager()

# =========================================================
# Model Management Endpoints
# =========================================================

@router.post("/models/set_custom_api")
async def set_custom_api(req: dict):
    api_url = req.get("api_url", "").strip()
    api_key = req.get("api_key", "").strip()
    model_name = req.get("model_name", "").strip()
    if not api_url or not model_name:
        raise HTTPException(400, "api_url and model_name are required")
    manager.switch_to_custom_api(api_url, api_key, model_name)
    return {"status": "ok", "provider": "custom", "model_name": model_name}

@router.get("/models/status")
async def models_status():
    running = check_ollama_running()
    return {"ollama_running": running, "current_model": manager.llm_backend.model_name}

@router.get("/models/catalog")
async def models_catalog():
    installed = list_installed_models()
    catalog = get_model_catalog(installed)
    return {"current_model": manager.llm_backend.model_name, "installed": installed, "catalog": catalog}

@router.post("/models/pull")
async def models_pull(req: dict):
    model_id = req.get("model_id", "")
    if not model_id: raise HTTPException(400, "model_id required")
    start_pull(model_id)
    return {"status": "started", "model_id": model_id}

@router.get("/models/pull_progress/{model_id}")
async def models_pull_progress(model_id: str):
    return get_pull_progress(model_id)

@router.post("/models/switch")
async def models_switch(req: dict):
    model_id = req.get("model_id", "")
    if not model_id: raise HTTPException(400, "model_id required")
    installed = list_installed_models()
    if model_id not in installed:
        raise HTTPException(400, f"Model {model_id} is not installed. Pull it first.")
    manager.switch_model(model_id)
    return {"status": "ok", "current_model": model_id}

# =========================================================
# Game API Endpoints
# =========================================================

@router.post("/start_game")
async def start_game(req: StartGameRequest):
    logger.info(f"New game: [{req.character_name}] born in [{req.world_key}]")
    try:
        world_config = load_world_config(req.world_key)
        manager.session = GameSession(
            llm=manager.llm_backend, world_config=world_config,
            char_name=req.character_name, gender=req.gender,
            difficulty=req.difficulty, stats=req.stats
        )
        return manager.session.get_state_snapshot()
    except Exception as e:
        logger.error(f"Start game error: {e}")
        raise HTTPException(500, str(e))

@router.get("/get_state")
async def get_state():
    if not manager.session: raise HTTPException(400, "No active session")
    return manager.session.get_state_snapshot()

@router.get("/generate_event")
async def generate_event():
    if not manager.session: raise HTTPException(400, "No active session")
    return manager.session.generate_next_event()

@router.post("/roll_dice")
async def roll_dice(req: NormalChoiceRequest):
    if not manager.session: raise HTTPException(400, "No active session")
    return manager.session.roll_dice(req.choice_index)

@router.post("/resolve_narrative")
async def resolve_narrative():
    if not manager.session: raise HTTPException(400, "No active session")
    return manager.session.resolve_narrative()

@router.post("/submit_node_choice")
async def submit_node_choice(req: NodeChoiceRequest):
    if not manager.session: raise HTTPException(400, "No active session")
    return manager.session.submit_node_investments(req.investments)

@router.post("/resolve_node_narrative")
async def resolve_node_narrative():
    if not manager.session: raise HTTPException(400, "No active session")
    return manager.session.resolve_node_narrative()

@router.get("/get_leaderboard")
async def get_leaderboard():
    return AchievementSystem.get_leaderboard()

@router.post("/leaderboard/submit")
async def submit_to_leaderboard(req: dict):
    if not manager.session: 
        raise HTTPException(400, "No active session to upload")
    
    score = AchievementSystem.calculate_score(manager.session)
    bio = req.get("biography", "An ordinary life.")
    hist = getattr(manager.session, "history", [])
    
    AchievementSystem.save_to_leaderboard(
        name=manager.session.character_name,
        score=score,
        cause=manager.session.cause_of_death,
        age=manager.session.age,
        world=manager.session.world_name,
        biography=bio,
        history=hist
    )
    return {"status": "success", "score": score}