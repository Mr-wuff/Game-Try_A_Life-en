import random
import logging
from typing import Dict, Any

from systems.inventory_sys import InventorySystem
from .prompt_builder import PromptBuilder, STAT_KEYS

logger = logging.getLogger("LifeSim.Core.Resolver")

class EventResolver:
    @staticmethod
    def _sniff_cg_trigger(session: Any, text_to_scan: str, event_type: str, is_success: bool = True) -> str:
        """
        Scans the generated text for keywords to trigger CG videos configured in the world mod.
        event_type: 'node' (Tribulation) or 'normal' (Daily event)
        """
        cg_config = getattr(session, "world_config", {}).get("cg_triggers", [])
        if not cg_config:
            return ""
            
        text_lower = text_to_scan.lower()
        
        for trigger in cg_config:
            # 1. Check if the event type matches the trigger condition
            trigger_type = trigger.get("type", "any")
            if trigger_type != "any" and trigger_type != event_type:
                continue
                
            # 2. Scan for keywords
            keywords = trigger.get("keywords", [])
            for kw in keywords:
                if str(kw).lower() in text_lower:
                    # 3. Match found! Return the appropriate video file
                    if is_success:
                        return trigger.get("success_video", "")
                    else:
                        return trigger.get("fail_video", trigger.get("success_video", ""))
        return ""

    @staticmethod
    def calculate_roll(session: Any, choice_index: int) -> Dict[str, Any]:
        choices = session.current_event_data.get("choices", [])
        if choice_index < 0 or choice_index >= len(choices): choice_index = 0
            
        choice = choices[choice_index]
        check_stat_display = choice.get("check_stat", "luck")
        stat_key = session.display_to_stat.get(check_stat_display, check_stat_display).lower()
        player_stat_val = session.stats.get(stat_key, 0)
        
        try: difficulty = int(choice.get("difficulty", 40))
        except: difficulty = 40
            
        roll_max = 40
        if session.difficulty == "Hell": roll_max = 30
        elif session.difficulty == "Easy": roll_max = 50
            
        roll_val = random.randint(1, roll_max)
        total_roll = player_stat_val + roll_val
        is_success = total_roll >= difficulty
        
        session.pending_roll_context = {
            "choice_text": choice.get("text", "Unknown Choice"),
            "check_stat": check_stat_display,
            "base": player_stat_val,
            "roll": roll_val,
            "total": total_roll,
            "difficulty": difficulty,
            "is_success": is_success
        }
        return session.pending_roll_context

    @staticmethod
    def generate_outcome(session: Any) -> Dict[str, Any]:
        roll_ctx = getattr(session, "pending_roll_context", None)
        if not roll_ctx:
            return {"outcome_text": "System Error.", "stat_changes": {}, "is_dead": False}

        prompt = PromptBuilder.build_outcome_prompt(session, roll_ctx)
        sys_prompt = PromptBuilder.build_system_prompt(session, False)
        
        llm_data = session.llm.generate_json(prompt, sys_prompt)
        if not llm_data:
            msg = "Miraculously succeeded!" if roll_ctx['is_success'] else "Unfortunately, failed..."
            llm_data = {"outcome_text": msg, "stat_changes": {}, "items": [], "is_dead": False}

        return EventResolver._apply_llm_result(session, llm_data, is_node=False)

    @staticmethod
    def generate_node_outcome(session: Any) -> Dict[str, Any]:
        investments = getattr(session, "pending_node_investments", {})
        prompt = PromptBuilder.build_node_prompt(session, investments)
        sys_prompt = PromptBuilder.build_system_prompt(session, True)
        
        llm_data = session.llm.generate_json(prompt, sys_prompt, retry=3)
        if not llm_data:
            llm_data = {"outcome_text": "You barely survived the tribulation, but suffered heavy losses.", "stat_changes": {"hp": -50}, "is_dead": False}

        return EventResolver._apply_llm_result(session, llm_data, is_node=True)

    @staticmethod
    def _apply_llm_result(session: Any, llm_data: Dict[str, Any], is_node: bool) -> Dict[str, Any]:
        outcome = llm_data.get("outcome_text", "")
        
        new_tag = llm_data.get("new_causal_tag", "").strip()
        if new_tag and new_tag not in session.causal_tags:
            session.causal_tags.append(new_tag)
            
        items_raw = llm_data.get("items", [])
        if isinstance(items_raw, list):
            for item in items_raw:
                if isinstance(item, dict) and "name" in item:
                    try:
                        InventorySystem.add_item(session, item)
                        outcome += f"\n\n[Acquired]: {item['name']} - {item.get('description', '')}"
                    except: pass

        applied_changes = {}
        changes_raw = llm_data.get("stat_changes", {})
        if isinstance(changes_raw, dict):
            for k, v in changes_raw.items():
                sk = session.display_to_stat.get(k, k).lower()
                if sk in STAT_KEYS or sk == "hp":
                    try:
                        v_int = int(v)
                        max_limit = 200 if (sk == "hp" or is_node) else 100
                        session.stats[sk] = max(0, min(max_limit, session.stats.get(sk, 0) + v_int))
                        applied_changes[sk] = v_int
                    except: pass

        if llm_data.get("is_dead") or session.stats.get("hp", 0) <= 0:
            session.is_dead = True
            session.cause_of_death = "Turned to ash in the tribulation" if is_node else "An unfortunate accident"

        log_prefix = "[NODE] " if is_node else f"Age {session.age}: "
        session.history.append(f"{log_prefix} -> {outcome[:30]}...")
        if is_node: session.milestones.append({"age": session.age, "outcome": outcome})
        
        session.age_up()

        # ---------------------------------------------------------
        # [NEW] CG Sniffing Logic
        # ---------------------------------------------------------
        cg_video = ""
        scan_pool = session.current_event_data.get("event_description", "") + " " + outcome
        
        if is_node:
            survived = not session.is_dead
            cg_video = EventResolver._sniff_cg_trigger(session, scan_pool, "node", survived)
        else:
            roll_ctx = getattr(session, "pending_roll_context", {})
            is_success = roll_ctx.get("is_success", False)
            cg_video = EventResolver._sniff_cg_trigger(session, scan_pool, "normal", is_success)

        # ---------------------------------------------------------
        # Epic Biography Generation
        # ---------------------------------------------------------
        epic_ending = "An ordinary life etched into history." 
        if session.is_dead:
            try:
                epic_prompt = PromptBuilder.build_epic_ending_prompt(session)
                epic_data = session.llm.generate_json(epic_prompt, "You are an epic historian.")
                if epic_data and isinstance(epic_data, dict) and "biography" in epic_data:
                    epic_ending = epic_data["biography"]
                else:
                    epic_ending = f"A life forgotten by time. Died at {session.age} due to {session.cause_of_death}."
            except Exception as e:
                logger.error(f"Failed to generate epic biography: {e}")

        return {
            "outcome_text": outcome,
            "stat_changes": applied_changes,
            "is_dead": session.is_dead,
            "cause_of_death": session.cause_of_death,
            "epic_ending": epic_ending,
            "cg_play": cg_video  # Inject the video filename to the frontend
        }