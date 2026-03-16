"""
Modern City — World Configuration
A hyper-realistic contemporary urban setting. No magic, no fantasy, just raw human drama.
"""

WORLD_INFO = {
    "name": "Modern City",
    "display_name": "Modern City",
    "flavor": "In the concrete jungle, your story has only just begun.",
    "description": (
        "A sprawling 21st-century metropolis where skyscrapers tower over cramped apartments, "
        "the internet seeps into every corner of life, and social media can make or break you overnight. "
        "Money talks, office politics cut deep, and the gap between the haves and have-nots grows wider every day."
    ),
    "rules": (
        "[Core Law] Strictly realistic. No supernatural, magic, cultivation, psychic, or unexplained phenomena.\n"
        "[Social Rules] The legal system is robust, but connections, money, and public opinion often matter more than truth. "
        "Cyberbullying, doxxing, and 'cancel culture' are real threats.\n"
        "[Conflict Style] Modern conflicts are economic, interpersonal, and psychological. Direct physical combat is extremely rare."
    ),
    "common_events": [
        "Academic competition", "Office politics", "Online scam", "Blind date disaster",
        "Startup failure", "Rental dispute", "Influencer drama", "Medical checkup",
        "Traffic violation", "Friend asking for a loan", "Parents pressuring marriage",
        "Child education stress", "Inheritance dispute", "Mental health crisis",
        "Layoff notice", "Midlife career change", "Investment gone wrong"
    ],
    "special_notes": "All events must be grounded in materialist reality. Absolutely no talking animals, magic, flying, shapeshifting, superpowers, or system panels."
}

ATTRIBUTE_MAP = {
    "display_names": {
        "constitution": "Health", "intelligence": "Education", "charisma": "Looks",
        "wealth": "Savings", "luck": "Fortune", "social": "Connections", "willpower": "Resilience",
    },
    "descriptions": {
        "Health": "Physical fitness, disease resistance, energy levels. Too low risks sudden illness.",
        "Education": "Academic knowledge, career skills, logical thinking. Key for exams and promotions.",
        "Looks": "Physical appearance and first impressions. Affects dating, social media potential, but high looks can also attract unwanted attention.",
        "Savings": "Disposable income. Affects lifestyle quality, investment opportunities, and ability to weather financial storms.",
        "Fortune": "Probability of encountering lucky breaks — running into the right person, finding unexpected opportunities.",
        "Connections": "Social network breadth. Affects job hunting, getting favors, and receiving insider information.",
        "Resilience": "Mental toughness under stress, rejection, and cyberbullying. Too low risks depression or breakdown.",
    },
}

WORLD_SPECIFIC_RULES = (
    "[Modern City Check Preferences]\n"
    "Modern society rarely involves physical combat. Checks should primarily use:\n"
    " - Academic/Career → Education, Resilience\n"
    " - Financial issues → Savings, Connections\n"
    " - Romance/Social → Looks, Connections\n"
    " - Random events → Fortune, Health (illness/accident)\n"
    "[Penalty Style] Penalties typically reduce Savings, Resilience, or Connections. "
    "Direct HP loss is extremely rare (only car accidents, serious illness, overwork death).\n"
    "[Writing Style] Events should include psychological detail and social nuance. "
    "Use metaphors, dialogue, and environmental details. Describe the neon lights outside the window, "
    "the silence of an empty office, the bitter taste of cold coffee."
)

AGE_CONSTRAINTS = {
    (0, 1):   "[Infant] Completely helpless. Cannot speak, walk, or use tools. Events only involve feeding, sleeping, illness, parental reactions.",
    (1, 3):   "[Toddler] Just learning to walk and say simple words. Limited cognition. Cannot go outside alone. Events involve family, neighbors, minor accidents.",
    (4, 6):   "[Preschool] Curious but closely supervised. Can involve kindergarten, playground, small peer conflicts. No independent economic activity.",
    (7, 9):   "[Elementary - Lower] Starting to read. Events focus on school, homework, playground games, simple friendships.",
    (10, 12): "[Elementary - Upper] Growing social awareness. May encounter peer pressure, early exposure to phones/internet. Still cannot travel independently.",
    (13, 15): "[Middle School] Puberty begins. Rebellious phase. Academic pressure, puppy love, gaming addiction. Economically dependent on parents.",
    (16, 18): "[High School] Academic competition intensifies. College entrance exams dominate everything. Emotional awakening but suppressed by study pressure.",
    (19, 22): "[College] First taste of freedom. Dating, socializing, internships. Financially dependent but can take part-time jobs.",
    (23, 28): "[Early Career] Job hunting, renting, adapting to the workplace. Marriage pressure from family. Thin financial foundation.",
    (29, 35): "[Career Building] Key career period. Promotion battles, startup risks, marriage pressure. Health starts declining.",
    (36, 45): "[Midlife Burden] Supporting aging parents and young children. Mortgage, car payments, career plateau, emotional vulnerability.",
    (46, 55): "[Late Career] Energy declining. Children leaving home. Empty nest syndrome. Focus shifts to retirement planning.",
    (56, 65): "[Pre-Retirement] Approaching retirement. Workplace marginalization. May take on hobbies or part-time consulting.",
    (66, 75): "[Retirement] Pension life. Chronic health issues emerge. Grandchildren, morning exercises, health supplements.",
    (76, 100): "[Twilight Years] Limited mobility. Memory fading. Friends and family passing away. Events focus on medical care, reminiscence, end-of-life decisions.",
}

NODE_AGES = [6, 12, 15, 18, 22, 25, 30, 35, 40, 50, 60]
NODE_EVENT_TEMPLATES = {
    6:  "You hold your mother's hand, standing before the unfamiliar school gates. Sunlight filters through the trees. She looks at you with misty eyes. This is your first step into the world alone.",
    12: "The exam results are out. You hover over the 'Check Score' button, heart pounding. Your parents wait anxiously in the living room. The air feels frozen.",
    15: "The night before your high school entrance exam, you can't sleep. Staring at the city lights through your window, you wonder for the first time: who am I going to become?",
    18: "The final bell rings. You walk out of the exam hall into the rain. You can't tell if the wetness on your face is rain or tears. Everything you've worked for comes down to this.",
    22: "Graduation day. Caps fly into the air. Friends embrace and say goodbye. You know some of these people you'll never see again.",
    25: "Holiday dinner. Relatives take turns: 'Seeing anyone?' 'How much do you make?' You raise your glass with a bitter smile.",
    30: "The office lights are still on. You rub your aching eyes. Your phone buzzes — mortgage payment deducted. The tutoring bill is due next week.",
    35: "Your father is suddenly hospitalized. You take time off to sit by his bed. Looking at his aged face, you realize for the first time: you're not young anymore either.",
    40: "The layoff list comes out. Your name is on it. On the drive home, you smoke an entire pack of cigarettes.",
    50: "The medical report shows multiple abnormal readings. The doctor recommends immediate lifestyle changes. You sit in silence.",
    60: "Retirement paperwork complete. You close your office door for the last time. The hallway is empty. You walk down the stairs slowly.",
}

AGE_THEMES = {
    (0, 3): [
        "It's 3 AM and you're crying again. Mom rocks you gently, humming an off-key lullaby. You smell warm milk and slowly quiet down.",
        "You try to stand up for the first time, wobble toward the coffee table, and smack your knee on the corner. The tears haven't even started when a candy appears in your hand.",
        "Dad holds up his phone, flash blinding you. 'Say dada!' he coos. You just stare, confused.",
    ],
    (4, 6): [
        "First day of kindergarten. You cling to Mom's leg, screaming. The teacher gently pries your fingers loose. You cry until your voice is hoarse.",
        "You and the neighbor kid fight over a toy. You win, but go home with three scratch marks on your face. Mom scolds you.",
        "You yell a cartoon catchphrase at the family cat. The cat yawns and walks away.",
    ],
    (7, 12): [
        "Your seatmate draws a line down the middle of the desk with a pencil. Cross it and you get jabbed in the elbow.",
        "You sneak a five-dollar bill from Mom's wallet to buy candy. You share it with a friend in the stairwell. That evening you can't look Mom in the eye.",
        "An older kid blocks your way home and demands your lunch money. You hand it over. For a week you take the long way around.",
    ],
    (13, 18): [
        "Study hall. The classroom is silent except for the ceiling fan whirring. You're secretly reading a novel on your phone when the teacher's face appears at the window.",
        "You slip a note into your crush's textbook, heart racing. The next day, they act like nothing happened.",
        "The countdown board shows fewer days every morning. You can't sleep. At midnight you stand on the balcony, staring at the city lights.",
    ],
    (19, 23): [
        "Your roommate snores. You toss and turn — tomorrow is your first job interview. You've rewritten your resume three times.",
        "You meet an online friend in person. They're heavier than their photos but kind. You walk through the park all afternoon. In the end, you both know it won't work.",
        "Your part-time job scams you out of the deposit. Sitting on the curb, you realize for the first time how hard it is to make money.",
    ],
    (24, 35): [
        "Final all-nighter before launch. You stare at the screen, eyes barely open. The coffee makes you nauseous.",
        "Your blind date asks if you have a house, a car, and how much you earn. You dodge the question with a laugh, but something aches inside.",
        "Late at night you see an old college friend's promotion post online. You hit 'like,' then look around your rented apartment and sigh.",
    ],
    (36, 50): [
        "Your kid hands you a failed test paper to sign. You're about to explode, then remember — you were the same at their age.",
        "Class reunion. The prom queen got heavy, the valedictorian went bald. Everyone's comparing kids and houses. You excuse yourself to the restroom and don't come back for a while.",
        "Mom says on the phone, 'My back hurts again.' Your heart clenches. You book a ticket home for the weekend.",
    ],
    (51, 100): [
        "Morning walk in the park. A group of old men play chess under a tree. They call you 'young man.' You smile.",
        "It's been three years since your spouse passed. You visit the cemetery today with a bouquet of their favorite flowers. The wind blows. It feels like their hand on your cheek.",
        "Your grandchild asks, 'Grandpa, what was your dream when you were young?' You pause. You think for a long, long time.",
    ],
}

FORBIDDEN_PATTERNS = [
    r'magic', r'wizard', r'cultivation', r'spiritual energy', r'supernatural',
    r'telekinesis', r'telepathy', r'invisibility', r'shape.?shift', r'immortal',
    r'elf', r'dragon', r'portal', r'time travel', r'alien', r'superpower',
    r'flying\s+human', r'talking\s+animal', r'animal.*spoke', r'ghost', r'spirit realm',
    r'baby.*driving', r'infant.*phone', r'toddler.*invest', r'infant.*fight',
]

CHARACTER_CONFIG = {
    "start_age": 1,
    "max_age": 100,
    "initial_hp": 100,
    "birth_description": "A baby's first cry echoes through the delivery room. A new life has arrived.",
    "backstory": "You were born into a middle-class family in a bustling city."
}

REWARD_LIMITS = {"max_reward": 5, "max_penalty": -8, "hp_max_penalty": -15}

LOADING_TEXTS = {
    "birth": "A baby's first cry echoes through the delivery room...",
    "transition_titles": ["The days go by...", "Just another ordinary day?", "Life goes on...", "The city never stops for anyone..."],
    "flavor_texts": ["Neon lights flicker in the distance...", "Your phone buzzes once...", "Traffic hums outside the window...", "The coffee has gone cold...", "A convenience store bell chimes nearby...", "Another calendar page turns..."],
    "ending_divider": "— The city never stops for anyone —"
}

AGE_HEADERS = {
    "format": "life_stage",
    "stages": {
        "0-3": "Infant", "4-6": "Kindergarten", "7-12": "Elementary School",
        "13-15": "Middle School", "16-18": "High School", "19-22": "College",
        "23-30": "Young Professional", "31-40": "Career Prime", "41-50": "Midlife",
        "51-60": "Late Career", "61-70": "Retirement", "71-100": "Twilight Years"
    }
}

CG_TRIGGERS = [
    {
        "keywords": ["exam", "Score", "university", "college", "graduate", "高考", "成绩"],
        "type": "node",
        "success_video": "exam_success.ogv",
        "fail_video": "exam_fail.ogv"
    },
    {
        "keywords": ["layoff", "office", "fired", "mortgage", "裁员", "辞退"],
        "type": "node",
        "success_video": "", # No CG for success in a layoff scenario
        "fail_video": "layoff_fail.ogv"
    },
    {
        "keywords": ["hospital", "medical", "disease", "doctor", "医院", "体检"],
        "type": "node",
        "success_video": "morning_jog_success.ogv",
        "fail_video": "hospital_fail.ogv"
    }
]

PLACE_PATTERN = r'park|school|office|home|mall|street|hospital|restaurant|bar|gym|library|station|airport|hotel|cinema|cafe|bank|supermarket|subway|rooftop|parking lot|elevator'
COMMON_CHARACTERS = ["security guard", "police officer", "teacher", "classmate", "colleague", "boss", "subordinate", "client", "landlord", "agent", "doctor", "nurse", "delivery driver", "waiter", "cashier", "neighbor", "online friend", "ex", "crush", "blind date", "parents", "child", "relative", "stranger", "influencer"]

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
