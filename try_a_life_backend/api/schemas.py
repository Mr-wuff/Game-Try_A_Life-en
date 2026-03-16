from pydantic import BaseModel, Field
from typing import Dict


class StartGameRequest(BaseModel):
    world_key: str = Field(..., description="World identifier, e.g. 'modern_city', 'xianxia', 'medieval_war'")
    character_name: str = Field(..., description="Player's character name")
    gender: str = Field(..., description="Character gender: Male/Female/Random")
    difficulty: str = Field(..., description="Difficulty: Normal/Easy/Hard/Nightmare")
    stats: Dict[str, int] = Field(..., description="Initial stat allocation dict")


class NormalChoiceRequest(BaseModel):
    choice_index: int = Field(..., description="Index of the chosen option (0, 1, 2...)")


class NodeChoiceRequest(BaseModel):
    investments: Dict[str, int] = Field(..., description="Stat points invested into the node event")