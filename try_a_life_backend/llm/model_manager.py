"""
model_manager.py — Ollama Model Management API
Provides endpoints for listing available/installed models,
pulling new models with progress, and switching the active model.
"""

import json
import logging
import threading
import urllib.request
import urllib.error
from typing import Dict, Any, List

logger = logging.getLogger("LifeSimulator.ModelManager")

OLLAMA_BASE = "http://localhost:11434"

# ── Recommended models catalog ──────────────────────────
RECOMMENDED_MODELS = [
    {
        "id": "llama3.2:3b",
        "name": "Llama 3.2 3B",
        "size": "~2.0 GB",
        "vram": "~3 GB",
        "speed": "Fast",
        "quality": "Good",
        "description": "Best for low-end hardware. Fast responses, decent quality.",
        "tier": "budget",
    },
    {
        "id": "llama3.1:8b",
        "name": "Llama 3.1 8B",
        "size": "~4.7 GB",
        "vram": "~6 GB",
        "speed": "Medium",
        "quality": "Great",
        "description": "Recommended default. Best balance of speed and narrative quality.",
        "tier": "recommended",
    },
    {
        "id": "qwen2.5:7b",
        "name": "Qwen 2.5 7B",
        "size": "~4.4 GB",
        "vram": "~6 GB",
        "speed": "Medium",
        "quality": "Great",
        "description": "Strong multilingual support. Good for non-English worlds or mods.",
        "tier": "alternative",
    },
    {
        "id": "mistral:7b",
        "name": "Mistral 7B",
        "size": "~4.1 GB",
        "vram": "~6 GB",
        "speed": "Medium",
        "quality": "Great",
        "description": "Excellent creative writing. Good narrative variety.",
        "tier": "alternative",
    },
    {
        "id": "llama3.1:70b-q4_0",
        "name": "Llama 3.1 70B (Q4)",
        "size": "~40 GB",
        "vram": "~40 GB RAM",
        "speed": "Slow",
        "quality": "Exceptional",
        "description": "Premium quality. Requires 64GB+ RAM. CPU-only is very slow.",
        "tier": "premium",
    },
]

# ── Pull progress tracking ──────────────────────────────
_pull_lock = threading.Lock()
_pull_progress: Dict[str, Any] = {}  # model_id -> {status, percent, detail, error}
_pull_threads: Dict[str, threading.Thread] = {}


def _ollama_api(endpoint: str, method: str = "GET", data: dict = None, timeout: int = 10) -> Any:
    """Low-level Ollama API call."""
    url = f"{OLLAMA_BASE}{endpoint}"
    body = json.dumps(data).encode("utf-8") if data else None
    req = urllib.request.Request(url, data=body, method=method)
    req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return json.loads(resp.read().decode("utf-8"))


def check_ollama_running() -> bool:
    """Check if Ollama service is reachable."""
    try:
        _ollama_api("/api/tags", timeout=5)
        return True
    except Exception:
        return False


def list_installed_models() -> List[str]:
    """Return list of installed model IDs."""
    try:
        data = _ollama_api("/api/tags", timeout=10)
        models = data.get("models", [])
        return [m.get("name", "") for m in models]
    except Exception as e:
        logger.warning(f"Failed to list models: {e}")
        return []


def get_model_catalog(installed: List[str]) -> List[Dict]:
    """Return catalog with installed status."""
    result = []
    for m in RECOMMENDED_MODELS:
        entry = dict(m)
        entry["installed"] = m["id"] in installed
        result.append(entry)
    return result


def start_pull(model_id: str):
    """Start pulling a model in background thread."""
    with _pull_lock:
        if model_id in _pull_threads and _pull_threads[model_id].is_alive():
            return  # already pulling
        _pull_progress[model_id] = {"status": "starting", "percent": 0, "detail": "Initializing...", "error": ""}
        t = threading.Thread(target=_do_pull, args=(model_id,), daemon=True)
        _pull_threads[model_id] = t
        t.start()


def _do_pull(model_id: str):
    """Execute model pull with streaming progress."""
    try:
        url = f"{OLLAMA_BASE}/api/pull"
        payload = json.dumps({"name": model_id, "stream": True}).encode("utf-8")
        req = urllib.request.Request(url, data=payload, method="POST")
        req.add_header("Content-Type", "application/json")

        with urllib.request.urlopen(req, timeout=3600) as resp:
            buffer = b""
            while True:
                chunk = resp.read(4096)
                if not chunk:
                    break
                buffer += chunk
                while b"\n" in buffer:
                    line, buffer = buffer.split(b"\n", 1)
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        msg = json.loads(line.decode("utf-8"))
                    except:
                        continue
                    status = msg.get("status", "")
                    total = msg.get("total", 0)
                    completed = msg.get("completed", 0)
                    pct = int(completed / total * 100) if total > 0 else 0
                    with _pull_lock:
                        _pull_progress[model_id] = {
                            "status": "pulling",
                            "percent": pct,
                            "detail": status,
                            "error": "",
                        }

        with _pull_lock:
            _pull_progress[model_id] = {"status": "done", "percent": 100, "detail": "Download complete!", "error": ""}
        logger.info(f"Model {model_id} pulled successfully.")

    except Exception as e:
        logger.error(f"Failed to pull {model_id}: {e}")
        with _pull_lock:
            _pull_progress[model_id] = {"status": "error", "percent": 0, "detail": "", "error": str(e)}


def get_pull_progress(model_id: str) -> Dict:
    """Get current pull progress for a model."""
    with _pull_lock:
        return _pull_progress.get(model_id, {"status": "idle", "percent": 0, "detail": "", "error": ""})
