import json
import os
import time
import logging
from typing import List, Dict, Any
from dotenv import load_dotenv

# Try to import Supabase
try:
    from supabase import create_client, Client
    HAS_SUPABASE = True
except ImportError:
    HAS_SUPABASE = False

logger = logging.getLogger("LifeSim.Systems.Achievement")
SAVE_FILE = "data/leaderboard.json"

# Load .env environment variables
load_dotenv()
SUPABASE_URL = os.environ.get("SUPABASE_URL", "")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY", "")

supabase: Any = None
if HAS_SUPABASE and SUPABASE_URL and SUPABASE_KEY:
    try:
        supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
        logger.info("✅ Supabase cloud client initialized successfully.")
    except Exception as e:
        logger.error(f"❌ Failed to initialize Supabase: {e}")

class AchievementSystem:
    @staticmethod
    def calculate_score(session: Any) -> int:
        """Inherit your original scoring mechanism, along with survival rewards and penalties for unnatural deaths."""
        base = 0
        for k, v in session.stats.items():
            if isinstance(v, (int, float)) and k != "hp":
                base += int(v) * 2
                
        age_bonus = session.age * 5
        survival_bonus = max(0, (session.age - 50) * 5)
        
        death_penalty = 0
        cause_lower = session.cause_of_death.lower()
        if "old age" not in cause_lower and "natural" not in cause_lower:
            death_penalty = -50
            
        extra_bonus = len(getattr(session, 'causal_tags', [])) * 50 + len(getattr(session, 'inventory', [])) * 30
        
        total = base + age_bonus + survival_bonus + death_penalty + extra_bonus
        return max(0, total)

    @staticmethod
    def save_to_leaderboard(name: str, score: int, cause: str, age: int, world: str, biography: str, history: List[str]):
        # ==========================================
        # 1. Data cleaning and anti-cheating measures (Sanity & Anti-Cheat)
        # ==========================================
        safe_name = str(name)[:50] # Name limit length
        safe_bio = str(biography)[:2500] # Biography limit length, prevent memory overflow attacks
        
        # History records only keep the last 30 entries, and each entry is limited to 200 characters
        trimmed_history = history[-30:] if len(history) > 30 else history
        safe_history = [str(h)[:200] for h in trimmed_history] 
        
        # Score overflow check (Force upper limit of 500,000 points)
        safe_score = min(int(score), 500000)

        entry_data = {
            "player_name": safe_name,
            "world_name": world,
            "score": safe_score,
            "age": age,
            "cause_of_death": cause,
            "biography": safe_bio,
            "history": safe_history
        }

        # ==========================================
        # 2. Attempt cloud upload (Cloud Sync)
        # ==========================================
        cloud_success = False
        if supabase:
            try:
                # Write to the Supabase database
                supabase.table("leaderboard").insert(entry_data).execute()
                logger.info(f"☁️ Cloud upload successful: [{safe_name}] - {safe_score} pts")
                cloud_success = True
            except Exception as e:
                logger.error(f"☁️ Cloud upload failed (falling back to local): {e}")

        # ==========================================
        # 3. Local smoothing downgrade (Local Fallback)
        # ==========================================
        if not cloud_success:
            AchievementSystem._save_local(entry_data)

    @staticmethod
    def _save_local(entry_data: Dict[str, Any]):
        os.makedirs(os.path.dirname(SAVE_FILE), exist_ok=True)
        data = []
        if os.path.exists(SAVE_FILE):
            try:
                with open(SAVE_FILE, "r", encoding="utf-8") as f:
                    data = json.load(f)
            except Exception: pass
        
        # Map back to frontend-recognized field names
        local_entry = {
            "name": entry_data["player_name"],
            "world": entry_data["world_name"],
            "score": entry_data["score"],
            "age": entry_data["age"],
            "cause": entry_data["cause_of_death"],
            "biography": entry_data["biography"],
            "history": entry_data["history"],
            "date": time.strftime("%Y-%m-%d %H:%M")
        }
        
        data.append(local_entry)
        data = sorted(data, key=lambda x: x.get("score", 0), reverse=True)[:100]
        
        try:
            with open(SAVE_FILE, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            logger.info("💾 Saved to local fallback leaderboard.")
        except Exception as e:
            logger.error(f"❌ Local save failed: {e}")

    @staticmethod
    def get_leaderboard() -> List[Dict[str, Any]]:
        # ==========================================
        # 1. Attempt to fetch cloud data (Fetch from Cloud)
        # ==========================================
        if supabase:
            try:
                # Request the top 50 highest scores
                response = supabase.table("leaderboard").select("*").order("score", desc=True).limit(50).execute()
                cloud_data = []
                for row in response.data:
                    # Map back to Godot frontend-compatible structure
                    cloud_data.append({
                        "name": row.get("player_name", "Unknown"),
                        "world": row.get("world_name", "Unknown"),
                        "score": row.get("score", 0),
                        "age": row.get("age", 0),
                        "cause": row.get("cause_of_death", "Unknown"),
                        "biography": row.get("biography", ""),
                        "history": row.get("history", []),
                        "date": row.get("created_at", "")[:16].replace("T", " ")
                    })
                return cloud_data
            except Exception as e:
                logger.error(f"☁️ Failed to fetch cloud leaderboard (falling back to local): {e}")
        
        # ==========================================
        # 2. Local smoothing downgrade (Fetch from Local)
        # ==========================================
        if not os.path.exists(SAVE_FILE): return []
        try:
            with open(SAVE_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception: return []