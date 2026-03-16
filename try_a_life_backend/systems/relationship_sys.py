import logging
from typing import Any

logger = logging.getLogger("LifeSimulator.Systems.Relationship")

class RelationshipSystem:
    """The system class for managing the NPC's favorability and the global fate bond"""

    @staticmethod
    def add_causal_tag(session: Any, new_tag: str) -> None:
        """Add a fate bond, maintaining the queue length to prevent the prompt fed to the large model from becoming too long"""
        if not new_tag:
            return
            
        new_tag = new_tag.strip()
        if new_tag and new_tag not in session.causal_tags:
            session.causal_tags.append(new_tag)
            # Maintain at most 5 of the deepest recent bonds
            if len(session.causal_tags) > 5: 
                dropped_tag = session.causal_tags.pop(0)
                logger.debug(f"Forgot a distant bond: {dropped_tag}")
                
            logger.info(f"Formed a new bond: 【{new_tag}】")

    @staticmethod
    def update_npc_affinity(session: Any, npc_name: str, affinity_change: int, description: str = "") -> None:
        """Update the favorability dictionary for a specific NPC (lay the foundation for future bestiary or relationship systems)"""
        if not hasattr(session, "npc_relations"):
            session.npc_relations = {} # Initialize if not present

        if npc_name not in session.npc_relations:
            session.npc_relations[npc_name] = {"affinity": 0, "desc": description}
            
        session.npc_relations[npc_name]["affinity"] += affinity_change
        
        # Optionally update the description
        if description:
            session.npc_relations[npc_name]["desc"] = description
            
        logger.info(f"NPC [{npc_name}] favorability change: {affinity_change:+d} -> Current: {session.npc_relations[npc_name]['affinity']}")