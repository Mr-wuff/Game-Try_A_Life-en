import json
from typing import Dict, Any

STAT_KEYS = ["constitution", "intelligence", "charisma", "wealth", "luck", "social", "willpower"]

class PromptBuilder:
    @staticmethod
    def build_system_prompt(session: Any, is_node: bool = False) -> str:
        base = f"You are the core engine of a text adventure game set in the [{session.world_name}] world.\n"
        base += f"World Rules: {session.world_specific_rules}\n"
        if is_node:
            base += "[CRITICAL] This is a MAJOR TRIBULATION/BOSS BATTLE. Act as a ruthless heavenly judge. Strictly evaluate if the player's invested stats logically solve the crisis. If illogical, apply devastating penalties. If perfect, grant epic rewards."
        return base

    @staticmethod
    def build_event_prompt(session: Any, theme: str) -> str:
        prompt = f"""
Player: {session.character_name} (Gender: {session.gender}, Age: {session.age})
Stats: {json.dumps(session.stats)}
Life Theme this year: [{theme}]

Generate a random event or encounter for this year, with 2-3 choices.
Return strictly in JSON:
{{
    "event_description": "Vivid event description (max 80 words).",
    "choices": [
        {{
            "text": "Choice description",
            "check_stat": "Required stat (Constitution/Intelligence/Charisma/Wealth/Luck/Social/Willpower)",
            "difficulty": Integer (20-80)
        }}
    ]
}}
"""
        return prompt

    @staticmethod
    def build_outcome_prompt(session: Any, roll_context: Dict[str, Any]) -> str:
        is_success_str = "SUCCESS" if roll_context["is_success"] else "FAILURE"
        prompt = f"""
Event: {session.current_event_data.get('event_description')}
Player chose: [{roll_context['choice_text']}]
Dice Roll Result: [{is_success_str}] (Checked: {roll_context['check_stat']}, Base {roll_context['base']} + Roll {roll_context['roll']} = {roll_context['total']} vs Difficulty {roll_context['difficulty']}).

Player Stats: {json.dumps(session.stats)}

Based on the event, choice, and the dice [{is_success_str}], logically deduce the outcome.
Return strictly in JSON:
{{
    "outcome_text": "Detailed outcome description (max 100 words).",
    "stat_changes": {{"StatName": integer_change}},
    "items": [{{"name": "Item Name", "type": "permanent", "description": "Lore"}}],
    "new_causal_tag": "Short karma/grudge tag (or empty)",
    "is_dead": false (true ONLY if logically fatal)
}}
"""
        return prompt

    @staticmethod
    def build_node_prompt(session: Any, investments: Dict[str, int]) -> str:
        event_desc = session.current_event_data.get("event_description", "A massive crisis arrives.")
        prompt = f"""
[MAJOR TRIBULATION]
Event: {event_desc}
Player's remaining stats: {json.dumps(session.stats)}
Player sacrificed these stats to survive: {json.dumps(investments)}

Judge if the sacrificed stats logically solve this specific crisis:
1. If highly relevant and large amounts: Complete Victory (grant huge stat boosts and epic items).
2. If irrelevant or too little: Devastating Defeat (huge HP/stat loss, curses, or death).

Return strictly in JSON:
{{
    "outcome_text": "Epic description of how the stats affected the crisis (approx 150 words).",
    "stat_changes": {{"StatName": integer_change}},
    "items": [{{"name": "Item Name", "type": "permanent", "description": "Lore"}}],
    "new_causal_tag": "Epic destiny tag",
    "is_dead": false
}}
"""
        return prompt

    @staticmethod
    def build_epic_ending_prompt(session: Any) -> str:
        milestones_list = session.milestones[-10:] if hasattr(session, 'milestones') else []
        milestones_str = "\n".join([f"- Age {m.get('age', '?')}: {m.get('outcome', '')[:60]}..." for m in milestones_list])
        if not milestones_str:
            milestones_str = "- Lived a completely ordinary and quiet life."

        prompt = f"""
Player Name: {session.character_name}
World: {session.world_name}
Lifespan: {session.age} years
Cause of Death: {session.cause_of_death}

[Key Milestones & Tribulations]
{milestones_str}

Final Stats: {json.dumps(session.stats)}

Based on the player's lifespan, final stats, and key milestones, act as a legendary historian and write an epic, emotional, and engaging biography summarizing their life's journey (around 100-150 words). Highlight their rise, their struggles, and the tragedy of their death.

Return strictly in JSON format:
{{
    "biography": "The epic story goes here..."
}}
"""
        return prompt