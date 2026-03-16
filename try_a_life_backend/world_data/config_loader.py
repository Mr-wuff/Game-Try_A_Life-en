import os
import json
import re
import importlib
import logging
from typing import Dict, Any

logger = logging.getLogger("LifeSim.WorldData")

def load_world_config(world_key: str) -> Dict[str, Any]:
    """Multi-format config loader: JSON mods first, then built-in Python modules."""
    base_dir = os.path.dirname(os.path.abspath(__file__))
    json_path = os.path.join(base_dir, "worlds", f"{world_key}.json")

    if os.path.exists(json_path):
        logger.info(f"Loading JSON mod: [{world_key}.json]")
        return _load_json_config(json_path)

    module_map = {
        "modern_city": "world_data.worlds.modern_city",
        "xianxia": "world_data.worlds.xianxia",
        "medieval_war": "world_data.worlds.medieval_war",
    }

    if world_key in module_map:
        try:
            logger.info(f"Loading built-in world: [{world_key}]")
            module = importlib.import_module(module_map[world_key])
            return _process_config(module.WORLD_CONFIG)
        except Exception as e:
            logger.error(f"Failed to load world {world_key}: {e}")
            raise

    raise ValueError(f"Unknown world key: {world_key}. No .py or .json config found.")


def _load_json_config(filepath: str) -> Dict[str, Any]:
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    _parse_json_tuples(data, "age_themes")
    _parse_json_tuples(data, "age_constraints")
    if "node_templates" in data:
        data["node_templates"] = {int(k): v for k, v in data["node_templates"].items()}
    return _process_config(data)


def _parse_json_tuples(data: dict, key: str):
    if key in data and isinstance(data[key], dict):
        new_dict = {}
        for k, v in data[key].items():
            if isinstance(k, str) and "-" in k:
                try:
                    parts = k.split("-")
                    new_dict[(int(parts[0]), int(parts[1]))] = v
                except ValueError:
                    logger.warning(f"Invalid range key in {key}: {k}, skipped.")
            else:
                new_dict[k] = v
        data[key] = new_dict


def _process_config(config: Dict[str, Any]) -> Dict[str, Any]:
    attrs = config.get("attributes", {})
    if "display_to_stat" not in attrs and "display_names" in attrs:
        attrs["display_to_stat"] = {v: k for k, v in attrs["display_names"].items()}
    attrs.setdefault("descriptions", {})

    forbidden_list = config.get("forbidden_patterns", [])
    config["compiled_forbidden"] = [re.compile(p, re.IGNORECASE) for p in forbidden_list]

    # Initialize all default fields to prevent runtime errors
    config.setdefault("node_ages", [])
    config.setdefault("node_templates", {})
    config.setdefault("age_constraints", {})
    config.setdefault("age_themes", {})
    config.setdefault("world_specific_rules", "")
    config.setdefault("place_pattern", "")
    config.setdefault("common_characters", [])
    config.setdefault("character", {"start_age": 1, "max_age": 100, "initial_hp": 100,
                                     "birth_description": "A new destiny begins to unfold...", "backstory": ""})
    config.setdefault("npcs", [])
    config.setdefault("relationships", {})
    config.setdefault("reward_limits", {"max_reward": 5, "max_penalty": -8, "hp_max_penalty": -15})
    config.setdefault("loading_texts", {})
    config.setdefault("age_headers", {})
    config.setdefault("info", {"name": "Unknown World", "rules": "", "description": ""})
    
    # [New] Initialize CG triggers list for video playback mods
    config.setdefault("cg_triggers", [])
    
    return config