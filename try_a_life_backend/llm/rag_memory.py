import logging
from typing import List

logger = logging.getLogger("LifeSimulator.LLM.RAG")

class RAGMemorySystem:
    """
    Retrieval-Augmented Generation
    Solving the "amnesia" and "plot foreshadowing disruption" issues that occur when the character's age is too high in LLM。
    """
    def __init__(self):
        # Currently, we are using lightweight memory lists. In the future, this can be easily replaced with ChromaDB or FAISS vector retrieval.
        self.memory_store = []
        logger.info("RAG Memory Module Loaded (Current: Lightweight Memory Mode)")

    def add_memory(self, age: int, event_desc: str, outcome: str):
        """Imprint the significant moments of life into the memory of one's soul"""
        memory_snippet = f"At {age} years old: Encountered {event_desc[:30]}... The final outcome was: {outcome[:30]}..."
        self.memory_store.append(memory_snippet)

    def retrieve_relevant_memories(self, current_theme: str, top_k: int = 3) -> List[str]:
        """
        Based on the current life theme, retrieve the most relevant memories from the past.
        (Currently returns the most recent significant events; future versions will incorporate Sentence-Transformers cosine similarity calculations)
        """
        if not self.memory_store:
            return []
            
        # Basic implementation: prioritize returning the most memorable recent major events
        return self.memory_store[-top_k:]