import logging
from typing import Dict, Any, List

logger = logging.getLogger("LifeSimulator.Systems.Inventory")

class Item:
    """Standardized prop data model"""
    def __init__(self, name: str, description: str, item_type: str = "permanent", uses: int = 1, scope: str = "all"):
        self.name = name
        self.description = description
        self.type = item_type  # "permanent", "consumable"
        self.uses = uses if item_type == "consumable" else None
        self.scope = scope

    def to_dict(self) -> Dict[str, Any]:
        return {
            "name": self.name, 
            "description": self.description, 
            "type": self.type, 
            "uses": self.uses, 
            "scope": self.scope
        }

    @staticmethod
    def from_dict(d: Dict[str, Any]) -> 'Item':
        return Item(
            name=d.get("name", "Mysterious Item"), 
            description=d.get("description", "Emanates a faint glow."), 
            item_type=d.get("type", "permanent"), 
            uses=d.get("uses", 1), 
            scope=d.get("scope", "all")
        )

class InventorySystem:
    """Management system for player inventory logic"""

    @staticmethod
    def add_item(session: Any, item_data: Dict[str, Any]) -> None:
        """Safely add an item to the player's inventory, handling stacking logic"""
        try:
            new_item = Item.from_dict(item_data)
            
            # Check if the player already has an item with the same name
            existing_item = next((it for it in session.inventory if it.name == new_item.name), None)
            
            if existing_item:
                # If it is a consumable item, then increase the number of uses.
                if new_item.type == "consumable" and existing_item.type == "consumable":
                    existing_item.uses = (existing_item.uses or 1) + (new_item.uses or 1)
                    logger.info(f"Prop stacking: [{new_item.name}] has been increased to {existing_item.uses} times.")
                else:
                    logger.info(f"Duplicate permanent item obtained: [{new_item.name}], ignored.")
            else:
                session.inventory.append(new_item)
                logger.info(f"New item obtained: [{new_item.name}] - {new_item.description}")
        except Exception as e:
            logger.error(f"Failed to parse and add prop: {e} | Data: {item_data}")

    @staticmethod
    def consume_item(session: Any, item_name: str) -> bool:
        """Consume an item once, remove it if uses are depleted. Return whether consumption was successful."""
        for it in session.inventory:
            if it.name == item_name:
                if it.type == "consumable":
                    it.uses = (it.uses or 1) - 1
                    if it.uses <= 0:
                        session.inventory.remove(it)
                        logger.info(f"Prop [{item_name}] has been depleted, removed from inventory.")
                return True
        return False

    @staticmethod
    def get_inventory_list(session: Any) -> List[Dict[str, Any]]:
        """Get the serialized inventory list for frontend API use"""
        return [item.to_dict() for item in session.inventory]