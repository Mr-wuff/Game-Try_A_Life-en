import random
import logging
from typing import Dict, Any, Optional

from .prompt_builder import PromptBuilder, STAT_KEYS
from .event_resolver import EventResolver

logger = logging.getLogger("LifeSim.Core")

class GameSession:
    def __init__(self, llm, world_config: Dict[str, Any], char_name: str,
                 gender: str, difficulty: str, stats: Dict[str, int]):
        self.llm = llm
        self.config = world_config
        self.world_info = world_config["info"]
        self.world_name = self.world_info["name"]
        self.attr_cfg = world_config["attributes"]
        self.node_ages = world_config.get("node_ages", [])
        self.node_templates = world_config.get("node_templates", {})
        self.age_themes = world_config.get("age_themes", {})
        self.world_specific_rules = world_config.get("world_specific_rules", "")
        self.display_to_stat = self.attr_cfg.get("display_to_stat", {})
        self.stat_to_display = self.attr_cfg.get("display_names", {})

        char_cfg = world_config.get("character", {})
        self._start_age = char_cfg.get("start_age", 1)
        self._max_age = char_cfg.get("max_age", 100)
        self._initial_hp = char_cfg.get("initial_hp", 100)

        self.character_name = char_name
        self.gender = gender
        self.difficulty = difficulty
        self.age = self._start_age
        self.stats = stats
        if "hp" not in self.stats:
            self.stats["hp"] = self._initial_hp

        self.is_dead = False
        self.cause_of_death = ""
        self.history = []
        self.milestones = []
        self.causal_tags = []
        self.inventory = []
        self.npc_relations = {}
        self.current_event_data = None
        self.pending_roll_context = None 
        self.pending_node_investments = None
        logger.info(f"[System] Session initialized: [{char_name}] born in [{self.world_name}], start age {self.age}")

    def get_display_name(self, stat_key: str) -> str:
        return self.stat_to_display.get(stat_key, stat_key)

    def get_state_snapshot(self) -> Dict[str, Any]:
        return {
            "character_name": self.character_name,
            "age": self.age,
            "stats": self.stats,
            "is_dead": self.is_dead,
            "cause_of_death": self.cause_of_death,
            "inventory": getattr(self, "inventory", []),
            "causal_tags": getattr(self, "causal_tags", [])
        }

    def age_up(self):
        if self.is_dead: return
        self.age += 1
        self.stats["hp"] -= 1
        if self.stats["hp"] <= 0:
            self.is_dead = True; self.cause_of_death = "Died of old age"
        elif self.age >= self._max_age:
            self.is_dead = True; self.cause_of_death = "Reached the end of natural lifespan"

    def generate_next_event(self) -> Dict[str, Any]:
        if self.age in self.node_ages:
            desc = self.node_templates.get(self.age, f"A critical moment arrives at age {self.age}.")
            self.current_event_data = {"type": "node", "event_description": desc, "current_stats": self.stats, "choices": []}
            return self.current_event_data

        theme = next((random.choice(th) for (lo, hi), th in self.age_themes.items() if lo <= self.age <= hi), "An uneventful day")
        prompt = PromptBuilder.build_event_prompt(self, theme)
        sys = PromptBuilder.build_system_prompt(self, is_node=False)
        data = self.llm.generate_json(prompt, sys)
        if not data or "choices" not in data or not isinstance(data["choices"], list):
            data = {"event_description": "A quiet year passes without incident.",
                    "choices": [{"text": "Go about your day", "check_stat": "luck", "difficulty": 10}]}
        data["type"] = "normal"
        self.current_event_data = data
        return data

    def roll_dice(self, choice_index: int) -> Dict[str, Any]:
        return EventResolver.calculate_roll(self, choice_index)

    def resolve_narrative(self) -> Dict[str, Any]:
        return EventResolver.generate_outcome(self)

    def submit_node_investments(self, investments: Dict[str, int]) -> Dict[str, Any]:
        for stat, val in investments.items():
            if stat in self.stats:
                self.stats[stat] = max(0, self.stats[stat] - val)
        self.pending_node_investments = investments
        return {"status": "invested"}

    def resolve_node_narrative(self) -> Dict[str, Any]:
        return EventResolver.generate_node_outcome(self)