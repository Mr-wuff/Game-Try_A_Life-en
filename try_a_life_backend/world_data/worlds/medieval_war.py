"""
Medieval Warring States — World Configuration
A gritty, historical low-fantasy setting of feudal warfare, famine, and political intrigue.
"""

WORLD_INFO = {
    "name": "Medieval Warring States",
    "display_name": "Medieval Warring States",
    "flavor": "White bones lie in the fields. No rooster crows for a thousand miles. Will you forge your own path — or be crushed beneath history's wheel?",
    "description": (
        "An era of collapsing dynasties, warlord fiefdoms, and mass displacement — loosely inspired by "
        "the Five Dynasties and Ten Kingdoms period. Noble houses control every path to advancement. "
        "Common folk can only rise through military service or attaching themselves to the powerful. "
        "There are no wizards here — only flesh-and-blood humans, cold steel, and difficult choices."
    ),
    "rules": (
        "[Social Law] Feudal hierarchy. Imperial authority above all. Birth determines starting position. Military merit can change fate, but rebellion and purges follow close behind.\n"
        "[Survival Law] Constant warfare, famine, and plague. Life is cheap. A sack of grain may be worth more than a human life.\n"
        "[Historical Law] Strictly realistic. Cold weapons only. No supernatural powers. Even the bravest warrior cannot stand against an army. Even the deepest scheme cannot predict the human heart."
    ),
    "common_events": [
        "Imperial examination", "Border war", "Palace coup", "Bandit ambush",
        "Disaster relief", "Peasant revolt", "Private school studies", "Conscription",
        "Battlefield carnage", "Siege warfare", "Mutiny", "Buying an office",
        "Political faction struggle", "Corruption charges", "False treason accusation",
        "Refugee flight", "Plague outbreak", "Crushing taxes", "Clan feud",
        "Marriage alliance", "Family annihilation", "Becoming an outlaw"
    ],
    "special_notes": "All events must be grounded in historical realism. Archaic, solemn tone. Extreme emphasis on class divide, survival desperation, and moral struggle. Absolutely no modern technology, supernatural powers, or romanticized martial arts."
}

ATTRIBUTE_MAP = {
    "display_names": {
        "constitution": "Martial Prowess", "intelligence": "Strategy", "charisma": "Renown",
        "wealth": "Treasury", "luck": "Fortune", "social": "Connections", "willpower": "Resolve",
    },
    "descriptions": {
        "Martial Prowess": "Combat ability, physical labor, disease resistance. Higher means better survival on the battlefield.",
        "Strategy": "Tactical planning, scholarship, imperial exam essays, ability to see through political schemes.",
        "Renown": "Reputation among people and scholars. Affects recruitment, public trust, and noble attention — but too much fame invites suspicion.",
        "Treasury": "Money, grain, and land. Can hire soldiers, bribe officials, or buy survival in famine years.",
        "Fortune": "Probability of meeting benefactors, finding hidden things, dodging stray arrows. Fate smiles on the lucky.",
        "Connections": "Ability to befriend heroes and officials. Opens doors, finds patrons, but debts always come due.",
        "Resolve": "Mental fortitude under torture, defeat, or temptation. Determines whether you bend or break when fate strikes.",
    },
}

WORLD_SPECIFIC_RULES = (
    "[Medieval Warring States Check Preferences]\n"
    "Events center on life, death, clan survival, and political power:\n"
    " - Battlefield / Disease → Martial Prowess\n"
    " - Court intrigue / Exams / Tactics → Strategy\n"
    " - Bribery / Famine survival → Treasury\n"
    " - Last stand / Torture / Loyalty test → Resolve\n"
    " - Alliance / Patronage → Connections or Renown\n"
    "[Penalty Style] Brutally harsh. Failed checks can mean death on the battlefield, "
    "clan execution, exile, or financial ruin. Success may mean promotion, sudden wealth, "
    "or fame — but remember: serving a king is like sleeping with a tiger.\n"
    "[Writing Style] Historical gravity. Specific details — the broken walls at sunset, "
    "the hollow eyes of refugees, the weight of armor, the silence before battle. No modern slang."
)

AGE_CONSTRAINTS = {
    (0, 3):   "[Infant] Infant mortality is sky-high. Completely dependent on parents. May be abandoned in wartime, hidden in cellars, or nearly killed by famine.",
    (4, 7):   "[Young Child] Poor children dig roots and gather firewood. Rich ones begin literacy lessons. Extremely fragile. Easily killed by plague or famine.",
    (8, 12):  "[Youth] Poor: herding cattle, begging, sold as servants. Rich: studying the classics. Can do light labor but has no independent agency.",
    (13, 15): "[Coming of Age] Boys may be conscripted or enter imperial examinations. Girls may be betrothed. Beginning to encounter the real world's brutality.",
    (16, 20): "[Adult] Formally grown. Facing conscription, examinations, arranged marriage, or fleeing as a refugee. Full agency but low status.",
    (21, 30): "[Prime] Peak years for building a career — whether on the battlefield, in the court, or in the underworld. Freedom of action but surrounded by mortal danger.",
    (31, 45): "[Middle Age] If alive, likely holds some position (officer, magistrate, landlord, bandit chief). Deep in political games. Family weighing on every decision.",
    (46, 60): "[Aging] Martial Prowess declining. Strategy and Connections at peak. Old wounds and illness. Focus on succession and protecting the family legacy.",
    (61, 80): "[Elder] Rare to reach this age. Retired, or facing one final reckoning with old enemies. Events center on legacy, memory, and quiet endings.",
}

NODE_AGES = [8, 15, 20, 25, 30, 35, 40, 45, 50, 60]
NODE_EVENT_TEMPLATES = {
    8:  "First day of school. Your father's rough hand on your shoulder, pointing at the schoolhouse door: 'Learn your letters, son. Then you won't have to dig dirt like me.' You nod, not quite understanding, and step inside.",
    15: "Outside the examination hall, the crowd is enormous. Your hands are sweating. The gong sounds. The gates open like the jaws of a beast.",
    20: "The training yard. You grip a spear for the first time. Across from you, a veteran's scarred face stares without pity. The commander waves his hand: 'Begin.' Steel flashes.",
    25: "The magistrate's back office. You're summoned to 'assist with an investigation.' The magistrate studies you, eyes narrow: 'I hear you know a certain someone...' Your blood runs cold.",
    30: "Promotion banquet. Colleagues toast you again and again. You drink yourself blind. At midnight, you wake to find an unsigned letter on your pillow.",
    35: "Siege. Three days under assault. You stand on the city wall, staring at the sea of torches below. You think of your wife and children inside. Tomorrow, you ride out for help.",
    40: "The throne room. A hundred officials stand silent. You kneel. The emperor's voice is ice: 'Someone accuses you of treason.' Sweat hits the marble tiles and evaporates instantly.",
    45: "The command tent. Generals argue. You say nothing, eyes fixed on the map. A scout bursts in: 'The enemy has cut our supply line!' Silence falls. You slowly rise.",
    50: "The family shrine. You kneel before the ancestral tablets. Your eldest son kneels beside you, waiting for your decision on dividing the estate. The candlelight flickers, carving shadows on your weathered face.",
    60: "Under the old tree at the village entrance, you hold your grandchild and tell stories of war. The child looks up: 'Grandpa, were you afraid of dying?' You gaze at the sunset and say nothing for a long time.",
}

AGE_THEMES = {
    (0, 3): [
        "Soldiers ransack the village. Your mother hides you in the cellar, blocking the entrance with her body. In the darkness, you hear footsteps and screams above. You dare not make a sound.",
        "You're starving, crying. Your father puts the last handful of grain porridge into your mouth. He licks the bowl clean himself. The next morning, he doesn't wake up.",
        "The wet nurse of the wealthy household secretly feeds you. Your mother kneels and bangs her head on the ground in gratitude, weeping.",
    ],
    (4, 7): [
        "A drought year. You follow the adults digging for roots and bark. When even the bark is gone, they start eating clay. You ask what it is. Your mother says, 'blessed earth.'",
        "You get lost at the market. A man in fine clothes takes your hand and asks your name. You burst into tears, drawing a crowd.",
        "Through the high window of the schoolhouse, you stand on stacked bricks to peek inside. The old teacher reads aloud: 'Man at birth is inherently good.' You whisper along.",
    ],
    (8, 12): [
        "Sold to a wealthy family as a page boy. The young master is two years younger and can slap you at will. At night, in the woodshed, you trace characters in the dirt with a stick.",
        "A wounded soldier stumbles into the village — one arm gone. Children mock him. He gives you a rusty copper coin: 'Buy yourself a bun, kid.'",
        "While herding cattle, you discover an abandoned tomb on the hillside, the entrance caved in. You peer inside, heart pounding. It's empty.",
    ],
    (13, 15): [
        "Conscription papers arrive. Three men from every family of five. Your brother goes. At the door, he looks back once, says nothing.",
        "Escorting the young lady to the temple, ruffians harass her. You step in front. One punch sends you to the ground.",
        "You fail the county exam. By the river, you tear your crib notes into pieces, one by one, dropping them into the water.",
    ],
    (16, 20): [
        "Wedding night. You lift the veil. A stranger's face. She grips her sleeves, head bowed. Outside, firecrackers roar. The room feels impossibly quiet.",
        "You crawl out of a pile of corpses, drenched in blood. Beside you lies your fellow villager — yesterday you shared a biscuit. You close his eyes and take his identification tag.",
        "Your first battle. You wet yourself. The officer kicks you: 'Coward!' Then an arrow finds him. He collapses into a pool of blood.",
    ],
    (21, 30): [
        "Awarded a commendation for bravery. You return home to show off, only to find the schoolhouse burned down and the teacher gone.",
        "A colleague invites you for drinks and keeps hinting that a certain general plans to rebel. You pretend to be drunk and don't sleep all night.",
        "Your wife struggles in labor. The midwife asks: 'Save the mother or the child?' You drop to your knees, head hitting the floor until it bleeds.",
    ],
    (31, 45): [
        "Accused of embezzling military funds. You sell everything to bribe a eunuch. The verdict: 'No evidence.' But your fortune is gone.",
        "Ordered to suppress a peasant uprising. The refugees look just like the villagers you grew up with. You close your eyes and give the order.",
        "Your daughter is selected for the imperial harem. At the carriage, she whispers through the curtain: 'Father, I won't be able to serve you anymore.' You turn away, old tears falling.",
    ],
    (46, 60): [
        "Your son picks a fight with a nobleman's heir. You go to apologize, and they leave you standing in the servants' hall for two hours.",
        "Old wounds flare up. Lying in bed, you think of brothers-in-arms from years past. You send someone to ask after them. Most are already gone.",
        "A new emperor. General amnesty. You walk out of prison into blinding sunlight. You have no idea where to go.",
    ],
    (61, 80): [
        "You settle in the countryside, teaching a handful of children to read. They call you 'Teacher.' For a moment, you see yourself as a boy again.",
        "A wandering monk comes through, saying your face is shadowed by misfortune. You laugh. This life was borrowed time from the start.",
        "Your grandchild begs for war stories. Halfway through, you stop. You wave your hand: 'Forgot. Forgot it all.'",
    ],
}

FORBIDDEN_PATTERNS = [
    r'phone', r'computer', r'internet', r'electric', r'car\b', r'airplane', r'train\b',
    r'gun\b', r'missile', r'rocket', r'bomb', r'tank\b', r'TV', r'fridge', r'microwave',
    r'social media', r'Wi-Fi', r'democracy', r'human rights', r'capitalism',
    r'magic', r'cultivation', r'spiritual energy', r'supernatural', r'shapeshif',
    r'immortal', r'flying sword', r'inner power', r'demon beast', r'divine beast',
]

CHARACTER_CONFIG = {"start_age": 1, "max_age": 80, "initial_hp": 100,
    "birth_description": "Amidst the fires of war, another life enters this broken world...",
    "backstory": "Born into a world of shattered dynasties and burning fields."}

REWARD_LIMITS = {"max_reward": 5, "max_penalty": -10, "hp_max_penalty": -20}

LOADING_TEXTS = {
    "birth": "Amidst the fires of war, another life enters this broken world...",
    "transition_titles": ["Seasons change, years slip away...", "Dynasties rise and fall...", "The winds of change are blowing...", "History's wheel rolls on..."],
    "flavor_texts": ["Candlelight wavers behind palace walls...", "War drums echo from afar...", "A sealed letter slips under the door...", "The night watchman's clapper draws near...", "Smoke rises from a distant village..."],
    "ending_divider": "— A few lines in the chronicle. Countless graves on the hill. —"
}

AGE_HEADERS = {"format": "era_title", "stages": {
    "0-3":"Infant","4-7":"Young Child","8-12":"Youth","13-15":"Coming of Age",
    "16-20":"Adulthood","21-30":"Prime Years","31-45":"Middle Age",
    "46-60":"Aging Veteran","61-80":"Elder"}}

CG_TRIGGERS = [
    {
        "keywords": ["examination hall", "treason", "emperor", "科举", "大殿", "诬陷"],
        "type": "node",
        "success_video": "court_success.ogv",
        "fail_video": "dungeon_fail.ogv"
    },
    {
        "keywords": ["Siege", "battle", "army", "spear", "城墙", "冲锋"],
        "type": "node",
        "success_video": "siege_success.ogv",
        "fail_video": "siege_fail.ogv"
    },
    {
        "keywords": ["family shrine", "ancestral", "heir", "祠堂", "传承"],
        "type": "node",
        "success_video": "shrine_success.ogv",
        "fail_video": "shrine_fail.ogv"
    }
]

PLACE_PATTERN = r'schoolhouse|county office|governor\'s hall|capital|village|farmland|mountain road|pass|borderland|barracks|battlefield|manor|tavern|teahouse|inn|market|temple|monastery|examination hall|prison|bandit camp|dock|bridge|wasteland|shrine|graveyard|stable|cellar|city wall|watchtower|granary|armory'
COMMON_CHARACTERS = ["schoolteacher", "fellow scholar", "examiner", "magistrate", "governor", "minister", "prime minister", "emperor", "general", "soldier", "bandit", "refugee", "beggar", "physician", "monk", "nun", "landlord", "merchant", "bodyguard", "night watchman", "jailer", "executioner", "clan elder", "tribal chieftain", "prince", "eunuch", "wet nurse", "page boy", "maidservant", "steward", "old comrade", "nemesis", "benefactor", "childhood friend"]

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
