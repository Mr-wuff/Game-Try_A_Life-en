import os
import json
import time
import logging
import urllib.request
from typing import Dict, Any

from .base import LLMBackend

logger = logging.getLogger("LifeSim.LLM.Ollama")

# Default model, overridable via environment variable ILS_MODEL
DEFAULT_MODEL = os.environ.get("ILS_MODEL", "llama3.1:8b")


class OllamaBackend(LLMBackend):
    """Ollama local LLM client. Zero third-party dependencies (uses urllib)."""

    def __init__(self, model_name: str = DEFAULT_MODEL, base_url: str = "http://localhost:11434"):
        self.model_name = model_name
        self.base_url = base_url.rstrip("/")
        logger.info(f"Connected to Ollama, model: [{model_name}]")

    def generate_json(self, prompt: str, system_prompt: str, retry: int = 1) -> Dict[str, Any]:
        payload = json.dumps({
            "model": self.model_name,
            "prompt": prompt,
            "system": system_prompt,
            "format": "json",
            "stream": False,
            "options": {"temperature": 0.6, "top_p": 0.9, "repeat_penalty": 1.05, "num_predict": 1200}
        }).encode("utf-8")

        for attempt in range(retry + 1):
            try:
                req = urllib.request.Request(f"{self.base_url}/api/generate", data=payload,
                                             headers={"Content-Type": "application/json"}, method="POST")
                with urllib.request.urlopen(req, timeout=180) as resp:
                    text = json.loads(resp.read().decode("utf-8")).get("response", "")
                    return self._clean_and_parse_json(text)
            except Exception as e:
                logger.warning(f"Ollama JSON generation failed (attempt {attempt+1}/{retry+1}): {e}")
                if attempt == retry:
                    logger.error("Max retries reached.")
                    return {}
                time.sleep(1)

    def generate_text(self, prompt: str, system_prompt: str) -> str:
        payload = json.dumps({
            "model": self.model_name,
            "prompt": prompt,
            "system": system_prompt,
            "stream": False,
            "options": {"temperature": 0.7, "num_predict": 600}
        }).encode("utf-8")
        try:
            req = urllib.request.Request(f"{self.base_url}/api/generate", data=payload,
                                         headers={"Content-Type": "application/json"}, method="POST")
            with urllib.request.urlopen(req, timeout=120) as resp:
                return json.loads(resp.read().decode("utf-8")).get("response", "").strip()
        except Exception as e:
            logger.error(f"Ollama text generation failed: {e}")
            return ""