import json
import re
import logging
from typing import Dict, Any

logger = logging.getLogger("LifeSim.LLM.Base")

class LLMBackend:
    def generate_json(self, prompt: str, system_prompt: str, retry: int = 1) -> Dict[str, Any]:
        raise NotImplementedError

    def generate_text(self, prompt: str, system_prompt: str) -> str:
        raise NotImplementedError

    @staticmethod
    def _clean_and_parse_json(raw_text: str, debug: bool = True) -> Dict[str, Any]:
        if not raw_text or raw_text.strip() == "":
            return {}

        text = re.sub(r'<think>.*?</think>', '', raw_text, flags=re.DOTALL)
        code_block = re.search(r'```(?:json)?\s*(\{.*?\})\s*```', text, re.DOTALL)
        if code_block:
            text = code_block.group(1)
        else:
            brace_match = re.search(r'(\{.*\})', text, re.DOTALL)
            if brace_match:
                text = brace_match.group(1)

        try:
            return json.loads(text.strip())
        except json.JSONDecodeError:
            if debug:
                logger.warning("JSON decode failed, engaging regex extraction fallback...")

            result = {}
            desc_match = re.search(r'"event_description"\s*:\s*"([^"]+)"', raw_text)
            if desc_match:
                result["event_description"] = desc_match.group(1)
            else:
                sentences = re.split(r'[.!?]', raw_text)
                result["event_description"] = (sentences[0].strip() + ".") if sentences and sentences[0].strip() else "Something unexpected happened."

            choices = []
            option_blocks = re.findall(r'\{[^{]*?"text"[^{]*?\}', raw_text, re.DOTALL)
            for opt_str in option_blocks:
                try:
                    opt = json.loads(opt_str)
                    if "text" in opt:
                        choices.append(opt)
                except:
                    opt_simple = {}
                    tm = re.search(r'"text"\s*:\s*"([^"]+)"', opt_str)
                    opt_simple["text"] = tm.group(1) if tm else "Make a mysterious decision"
                    sm = re.search(r'"check_stat"\s*:\s*"([^"]+)"', opt_str)
                    opt_simple["check_stat"] = sm.group(1) if sm else "luck"
                    dm = re.search(r'"difficulty"\s*:\s*(\d+)', opt_str)
                    opt_simple["difficulty"] = int(dm.group(1)) if dm else 30
                    sucm = re.search(r'"success_outcome"\s*:\s*"([^"]+)"', opt_str)
                    opt_simple["success_outcome"] = sucm.group(1) if sucm else "You succeeded."
                    failm = re.search(r'"fail_outcome"\s*:\s*"([^"]+)"', opt_str)
                    opt_simple["fail_outcome"] = failm.group(1) if failm else "You failed."
                    opt_simple["success_stat_changes"] = {}
                    opt_simple["fail_stat_changes"] = {}
                    opt_simple["is_dead"] = False
                    opt_simple["items"] = []
                    choices.append(opt_simple)

            if not choices:
                choices = [
                    {"text": "Wait and see", "check_stat": "luck", "difficulty": 10,
                     "success_outcome": "Nothing bad happens.", "fail_outcome": "You get dragged into trouble.",
                     "success_stat_changes": {}, "fail_stat_changes": {}},
                    {"text": "Take a risk", "check_stat": "constitution", "difficulty": 60,
                     "success_outcome": "A great reward!", "fail_outcome": "You get badly hurt.",
                     "success_stat_changes": {"charisma": 5}, "fail_stat_changes": {"hp": -10}}
                ]

            result["choices"] = choices
            lm = re.search(r'"location"\s*:\s*"([^"]+)"', raw_text)
            result["location"] = lm.group(1) if lm else "Unknown Place"
            return result