import json
import urllib.request
import urllib.error
import logging
import re
from typing import Dict, Any

from .base import LLMBackend

logger = logging.getLogger("LifeSim.LLM.CustomAPI")

class OpenAIBackend(LLMBackend):
    def __init__(self, api_key: str, base_url: str, model_name: str):
        self.api_key = api_key
        # 确保 url 不以斜杠结尾
        self.base_url = base_url.rstrip('/')
        self.model_name = model_name
        logger.info(f"Initialized Custom API: {self.model_name} at {self.base_url}")

    def generate_text(self, prompt: str, system_prompt: str = "", temperature: float = 0.7) -> str:
        url = f"{self.base_url}/chat/completions"
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.api_key}"
        }
        payload = {
            "model": self.model_name,
            "messages": [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": prompt}
            ],
            "temperature": temperature,
            # 限制回复长度，避免模型无限生成废话
            "max_tokens": 800 
        }
        
        data = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(url, data=data, headers=headers)
        
        try:
            with urllib.request.urlopen(req, timeout=30) as response:
                result = json.loads(response.read().decode("utf-8"))
                return result["choices"][0]["message"]["content"]
        except urllib.error.URLError as e:
            logger.error(f"Custom API Request failed: {e}")
            if hasattr(e, 'read'):
                logger.error(f"Error details: {e.read().decode('utf-8')}")
            return ""
        except Exception as e:
            logger.error(f"Unexpected error: {e}")
            return ""

    def generate_json(self, prompt: str, system_prompt: str = "", retry: int = 2) -> Dict[str, Any]:
        sys_prompt = system_prompt + "\n[CRITICAL] You MUST return strictly valid JSON. Do NOT wrap it in markdown code blocks (```json) or add any conversational text."
        
        for attempt in range(retry):
            text = self.generate_text(prompt, sys_prompt, temperature=0.4)
            if not text: continue
            
            try:
                # 强力剥离 Markdown 和废话
                match = re.search(r'(\{.*\}|\[.*\])', text, re.DOTALL)
                if match:
                    json_str = match.group(1)
                    return json.loads(json_str)
                return json.loads(text)
            except json.JSONDecodeError as e:
                logger.warning(f"Custom API JSON Parse failed (attempt {attempt+1}): {e}\nRaw output: {text}")
                
        logger.error(f"CRITICAL: Failed to get valid JSON from Custom API after {retry} attempts.")
        return None