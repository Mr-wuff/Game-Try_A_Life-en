"""
Immortal Cultivation (Xianxia) — World Configuration
A classic Chinese fantasy setting of cultivators, demonic beasts, and the pursuit of immortality.
"""

WORLD_INFO = {
    "name": "Immortal Cultivation",
    "display_name": "Immortal Cultivation (Xianxia)",
    "flavor": "Heaven and earth are the furnace. All things are copper. One seed of immortality, ten thousand fathoms of mortal dust.",
    "description": (
        "A world suffused with spiritual energy where humans, demons, and devil cultivators practice martial "
        "and mystical arts to ascend through cultivation realms (Qi Refining, Foundation Building, Golden Core, "
        "Nascent Soul, Spirit Transformation, Void Refining, Body Integration, Tribulation Transcendence). "
        "Sects dominate the landscape. The weak are prey. Treasure-hunting and killing are commonplace."
    ),
    "rules": (
        "[Cultivation Law] Spiritual energy, spirit roots, techniques, and elixirs exist. Breakthroughs are perilous — failure means cultivation loss or death.\n"
        "[Karma Law] Killing and stealing creates karmic debt that may manifest as inner demons during tribulation. Good deeds may pay off later.\n"
        "[Heavenly Dao] Powerful cultivators must not slaughter mortals wantonly, or face heavenly punishment.\n"
        "[Power Structure] Sects, clans, rogue cultivators, demon tribes, and devil cultivators vie for resources."
    ),
    "common_events": [
        "Sect tournament", "Secret realm exploration", "Demonic invasion", "Tribulation failure",
        "Finding a broken artifact", "Spirit beast bonding", "Alchemy furnace explosion",
        "Ambush and robbery", "Master-disciple ceremony", "Auction house bargain",
        "Technique epiphany", "Inner demon trial", "Ancient cave discovery", "Ascension tribulation"
    ],
    "special_notes": "All events must fit classical xianxia worldbuilding. Language should have an archaic, poetic tone. Absolutely no modern technology (phones, guns, internet, companies)."
}

ATTRIBUTE_MAP = {
    "display_names": {
        "constitution": "Physique", "intelligence": "Insight", "charisma": "Dao Affinity",
        "wealth": "Spirit Stones", "luck": "Destiny", "social": "Renown", "willpower": "Dao Heart",
    },
    "descriptions": {
        "Physique": "Body constitution. Affects combat endurance, tribulation survival, and HP ceiling.",
        "Insight": "Ability to comprehend techniques and formations. Key for breakthroughs and creating new arts.",
        "Dao Affinity": "Attractiveness to powerful cultivators, spirit beasts, and opportunities. Also affects dual cultivation.",
        "Spirit Stones": "The universal currency. Buys elixirs, artifacts, techniques, and bribes.",
        "Destiny": "Probability of finding treasure, encountering secret realms, and alchemy success.",
        "Renown": "Reputation in the cultivation world. Affects sect standing, alliance-building, and commanding rogue cultivators.",
        "Dao Heart": "Resistance to inner demons, illusions, and temptation. Determines breakthrough stability. Too low risks going berserk.",
    },
}

WORLD_SPECIFIC_RULES = (
    "[Xianxia Check Preferences]\n"
    "This is a brutal, romantic world of cultivation. Checks should use:\n"
    " - Combat/Injury → Physique\n"
    " - Comprehension/Formation → Insight\n"
    " - Resisting illusions/Inner demons → Dao Heart\n"
    " - Treasure hunting/Forging → Destiny\n"
    " - Negotiation/Intimidation → Renown or Dao Affinity\n"
    "[Penalty Style] Failure is devastating: massive HP loss, crippling injuries, or berserk (large Dao Heart/Insight drops). "
    "Success can yield artifacts, spirit stones, techniques, or major cultivation advancement.\n"
    "[Karma] Killing and robbery creates karma that haunts future tribulations. Good deeds may be rewarded later.\n"
    "[Writing Style] Use archaic, poetic language. Invoke imagery of clouds, swords, mountains, and fate. Avoid modern slang."
)

AGE_CONSTRAINTS = {
    (0, 5):   "[Mortal Child] No cultivation. Spirit root untested. Completely helpless. May attract attention due to innate anomalies.",
    (6, 10):  "[Spirit Root Testing] A mortal child about to be tested for spirit roots. Results determine the entire future — no root means no path to immortality.",
    (11, 20): "[Qi Refining / Outer Disciple] Barely stepped onto the path. Can only cast basic spells (firebolt, dust-clearing). Cannot fly on swords. Faces bullying and hard labor.",
    (21, 30): "[Foundation Building / Inner Disciple] Successfully built foundation. Can fly on swords. Lifespan ~200 years. Participates in tournaments, low-level secret realms, and demon hunts.",
    (31, 50): "[Golden Core / True Disciple] Formed a Golden Core. Lifespan ~500 years. Can forge a natal artifact. Faces life-and-death battles with peers.",
    (51, 150): "[Nascent Soul / Elder] Possesses a Nascent Soul — can survive body destruction. Lifespan ~1500 years. Often in seclusion or fighting for rare resources.",
    (151, 500): "[Spirit Transformation / Grand Elder] Merging soul with cosmic laws. Lifespan ~3000 years. Approaching transcendence. Faces heavenly tribulation.",
    (501, 1000): "[Void Refining / Patriarch] Perceiving the void. Lifespan 5000+. Events involve tribulations, legacy creation, and cross-realm warfare.",
}

NODE_AGES = [10, 20, 30, 40, 50, 60, 70, 80, 100, 150, 200, 300]
NODE_EVENT_TEMPLATES = {
    10:  "You stand on the Spirit Testing Platform, a rough jade stone in your palm. The elders' eyes, your parents' hopes, other children's envy — all rest upon you. The jade begins to glow...",
    20:  "The Foundation Building Pill dissolves. Spiritual energy churns within your dantian like boiling water. Sweat soaks through your robes. Succeed, and the path to immortality opens. Fail, and it closes forever.",
    30:  "Tribulation lightning tears the sky. You raise your artifact and grit your teeth against the first bolt. You remember the vow you made as a child — to live forever, to never look back.",
    40:  "You stand before a secret realm entrance. Ancient runes spell 'Death to trespassers.' Behind you, your companions hesitate. You take a breath and step forward. Beneath your feet: countless bones. Ahead: the unknown.",
    50:  "In your stone meditation chamber, inner demons surge without warning. You see your sect destroyed, your dao companion betrayed, your family slaughtered — all illusions, yet terrifyingly real. Falter, and you are lost forever.",
    60:  "The sect's grand formation falters. Devil cultivators mass like storm clouds. The sect master is wounded, elders fallen. You grip your natal artifact, step beyond the barrier. Today you fight for your sect — and yourself.",
    70:  "Spirit Transformation eludes you. After centuries of searching, you find a clue: dive into the Abyssal Chasm for Ten-Thousand-Year Cold Marrow. Nine deaths, one life.",
    80:  "At the auction, a fragment of what might be an Immortal Artifact draws every old monster's attention. Halfway through your bid, you feel hostile divine senses sweep over you. Is this treasure — or a death sentence?",
    100: "A century at Nascent Soul peak, yet the threshold to cosmic law remains sealed. You decide to scatter part of your cultivation and descend into the mortal world, seeking that one spark of enlightenment in the red dust.",
    150: "Your old enemy has become a Devil Dao overlord. The karma from a treasure you seized long ago has finally come due. You face them across the void, silently raising your artifact. In this world, there is no right or wrong — only life and death.",
    200: "Fifty years of death seclusion. Void Refining breakthrough imminent. Cosmic energy floods in. You feel yourself becoming something else entirely. The day you emerge is the day you face your tribulation.",
    300: "The Nine-Nine Heavenly Tribulation descends. Sky darkens, ten thousand thunderbolts fall. You look up and recall everything — love, hatred, gain, loss. Pass, and you ascend to the Immortal Realm. Fail, and you become ash.",
}

AGE_THEMES = {
    (0, 5): [
        "The night you were born, a shooting star crossed the sky. The clan elder said it was a sign of immortal destiny. Your mother held you tight, tears streaming down her face.",
        "At three, during the choosing ceremony, you grabbed a discarded jade slip and wouldn't let go. Your father shook his head. Your mother just smiled.",
        "At five, you had a terrible fever. In your dreams, a figure in white beckoned to you. When you woke, the fever was gone, but you had changed — quieter, more watchful.",
    ],
    (6, 10): [
        "The spirit root testing day approaches. Every night you lie awake, sneaking to the ancestral shrine to pray.",
        "The neighbor's boy tested positive for three spirit roots. The whole village celebrated. You stood in the crowd, heart burning with envy and fear.",
        "Your mother pressed her wedding jade pendant into your hand. 'Carry this,' she whispered. 'On the path to immortality, you'll need all the protection you can get.'",
    ],
    (11, 20): [
        "Accepted into the sect as the lowest-ranking servant. Every day: hauling water, chopping wood, enduring senior disciples' contempt. Late at night, you secretly practice the most basic qi-gathering technique.",
        "You saved three months of spirit stones to buy a Foundation Building Pill — it turned out to be a fake. Crouching against a wall, you tasted the cultivation world's cruelty for the first time.",
        "On a team mission in the beast forest, you saved a fellow disciple from a demon wolf. She blushed and thanked you. All you could do was grin awkwardly.",
    ],
    (21, 30): [
        "The day you built your foundation, you flew on a sword for the first time, soaring above the clouds, gazing down at mountains and rivers, and you couldn't help but shout. The world just got so much bigger.",
        "In a secret realm, you and your companions found a thousand-year spirit herb — only to be ambushed by rogue cultivators. After a bloody fight, you escaped with the herb. Behind you lay your companions' bodies.",
        "Sect tournament. You fought your way to the finals, only to lose to the head disciple. He patted your shoulder: 'Next time. I'll be waiting.'",
    ],
    (31, 50): [
        "Golden Core tribulation. You faced the thunder clouds alone. Lightning tore your flesh, but you never fell. When it was over, you earned the title of True Disciple.",
        "Forging your natal artifact. The blacksmith said: thirty percent chance. You hesitated, then nodded.",
        "Your first time off the mountain after forming your core. You met the senior who used to bully you. Now his cultivation lagged far behind yours. He looked at you with fear. You walked past without a word.",
    ],
    (51, 150): [
        "After reaching Nascent Soul, you carved out a cave dwelling and took disciples. Watching them practice, you often saw your younger self.",
        "An old acquaintance sought you out, saying they owed you a life debt. Only then did you recall — the rogue cultivator you casually saved decades ago was now a Nascent Soul peer.",
        "During an inner demon trial, you saw your worst fear: your dao companion dying in your arms while you stood helpless. When you awoke, she was beside you, watching with tear-filled eyes.",
    ],
    (151, 500): [
        "After Spirit Transformation, you began touching the laws of the cosmos. Day and night you meditated, but always felt a thin veil between you and true understanding. You knew — your heart wasn't ready yet.",
        "Your ancient enemy, now a Devil Dao titan, attacked the sect. You stood at the front line, gazing at that aged but familiar face, and silently raised your weapon.",
        "You decided to leave a legacy. In a hidden cave, you placed everything you had gained in your lifetime. Someday, centuries from now, someone would find it.",
    ],
    (501, 1000): [
        "Tribulation draws near. You feel Heaven's eye upon you. Every night you dream of countless cultivators turning to ash under heavenly lightning. You wake drenched in cold sweat.",
        "At the Ascension Platform, you look back. Everything in the mortal world — love, hatred, gain, loss — fades like mist. You breathe deep and step into the sea of thunder.",
        "The final bolt of the Nine-Nine Tribulation nearly scattered your soul. In that haze, you saw the white-robed figure from your childhood. They reached out their hand. You smiled. At last you understood — that was always you.",
    ],
}

FORBIDDEN_PATTERNS = [
    r'phone', r'computer', r'internet', r'electric', r'car\b', r'airplane', r'train\b', r'ship',
    r'gun\b', r'missile', r'rocket', r'bomb', r'tank\b', r'TV', r'fridge', r'microwave',
    r'social media', r'WeChat', r'TikTok', r'livestream', r'influencer', r'Wi-Fi',
    r'company', r'workplace', r'mortgage', r'credit card', r'stock market', r'interview',
    r'college entrance', r'university', r'resume', r'KPI', r'PowerPoint',
]

CHARACTER_CONFIG = {"start_age": 1, "max_age": 1000, "initial_hp": 100,
    "birth_description": "From the chaos of the void, a soul descends into the mortal realm...",
    "backstory": "Born into an ordinary clan at the edge of the cultivation world."}

REWARD_LIMITS = {"max_reward": 8, "max_penalty": -10, "hp_max_penalty": -20}

LOADING_TEXTS = {
    "birth": "From the chaos of the void, a soul descends into the mortal realm...",
    "transition_titles": ["Time flows, the Dao endures...", "Years pass, cultivation continues...", "Karma cycles, cause meets effect..."],
    "flavor_texts": ["Spiritual energy surges like a tide...", "The heavens conceal their secrets...", "A crane glides above the clouds...", "Flames dance in the alchemy furnace...", "Ancient runes shimmer on the jade slip..."],
    "ending_divider": "— The Dao is merciless, yet Heaven watches all —"
}

AGE_HEADERS = {"format": "realm", "stages": {
    "0-5":"Mortal Child","6-10":"Spirit Root Testing","11-20":"Qi Refining","21-30":"Foundation Building",
    "31-50":"Golden Core","51-150":"Nascent Soul","151-500":"Spirit Transformation","501-1000":"Tribulation Transcendence"}}


CG_TRIGGERS = [
    {
        "keywords": ["Spirit Testing", "jade", "Foundation Building", "筑基", "灵根"],
        "type": "node",
        "success_video": "foundation_success.ogv",
        "fail_video": "foundation_fail.ogv"
    },
    {
        "keywords": ["Tribulation", "lightning", "thunder", "ascend", "天劫", "雷劈"],
        "type": "node",
        "success_video": "tribulation_success.ogv",
        "fail_video": "tribulation_fail.ogv"
    },
    {
        "keywords": ["inner demons", "illusions", "devil", "心魔", "魔修"],
        "type": "node",
        "success_video": "meditation_success.ogv",
        "fail_video": "demon_fail.ogv"
    }
]

PLACE_PATTERN = r'spirit vein|secret realm|marketplace|sect|cave dwelling|ancient forest|ruins|battlefield|spirit field|alchemy room|scripture hall|training ground|forbidden zone|beast mountain|mortal village|immortal city|auction house|tribulation platform|ascension platform|sword tomb|medicine valley|abyss|volcano|altar'
COMMON_CHARACTERS = ["sect master", "elder", "inner disciple", "outer disciple", "servant", "rogue cultivator", "devil cultivator", "demon tribe", "alchemist", "artifact refiner", "formation master", "talisman crafter", "spirit beast", "mortal", "clan patriarch", "shopkeeper", "auctioneer", "mysterious elder", "senior brother", "junior sister", "nemesis", "dao companion", "inner demon", "tribulation avatar", "immortal"]

WORLD_CONFIG = {
    "info": WORLD_INFO, "attributes": ATTRIBUTE_MAP,
    "node_ages": NODE_AGES, "node_templates": NODE_EVENT_TEMPLATES,
    "forbidden_patterns": FORBIDDEN_PATTERNS, "age_themes": AGE_THEMES,
    "age_constraints": AGE_CONSTRAINTS, "world_specific_rules": WORLD_SPECIFIC_RULES,
    "place_pattern": PLACE_PATTERN, "common_characters": COMMON_CHARACTERS,
    "character": CHARACTER_CONFIG, "reward_limits": REWARD_LIMITS,
    "loading_texts": LOADING_TEXTS, "age_headers": AGE_HEADERS,
    "npcs": [], "relationships": {},
    "cg_triggers": CG_TRIGGERS
}
