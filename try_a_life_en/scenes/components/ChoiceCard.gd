extends Button
class_name ChoiceCard

var choice_index: int = -1
var difficulty_bar: ColorRect

func _get_difficulty_color(diff: int) -> Color:
	if diff <= 20: return Color(0.3, 0.9, 0.4, 0.8)
	if diff <= 40: return Color(0.9, 0.9, 0.2, 0.8)
	if diff <= 60: return Color(1.0, 0.6, 0.1, 0.8)
	return Color(1.0, 0.2, 0.2, 0.8)

# English stat icon mapping using internal keys
var check_stat_icons = {
	"constitution": "💪", "intelligence": "🧠", "charisma": "✨", "wealth": "💰",
	"luck": "🍀", "social": "🤝", "willpower": "🔥",
	# Also support display names from all 3 built-in worlds
	"Health": "💪", "Education": "🧠", "Looks": "✨", "Savings": "💰",
	"Fortune": "🍀", "Connections": "🤝", "Resilience": "🔥",
	"Physique": "💪", "Insight": "🧠", "Dao Affinity": "✨", "Spirit Stones": "💰",
	"Destiny": "🍀", "Renown": "🤝", "Dao Heart": "🔥",
	"Martial Prowess": "💪", "Strategy": "🧠", "Treasury": "💰", "Resolve": "🔥",
}

func _ready():
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)
	pressed.connect(_on_pressed)
	add_theme_font_size_override("font_size", 18)
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	custom_minimum_size = Vector2(0, 60)

func setup(index: int, data: Dictionary, delay_time: float = 0.0):
# Default to a generic icon if missing
	choice_index = index
	var btn_text = data.get("text", "...")
	var check_stat = data.get("check_stat", "luck")
	var diff = data.get("difficulty", 50)
	var icon = check_stat_icons.get(check_stat, "🎲")
	self.text = "  " + str(icon) + "  " + str(btn_text) + "\n      Check: " + str(check_stat) + " | DC: " + str(diff)
	difficulty_bar = ColorRect.new()
	difficulty_bar.color = _get_difficulty_color(diff)
	difficulty_bar.custom_minimum_size = Vector2(4, 0)
	difficulty_bar.size = Vector2(4, 60)
	difficulty_bar.position = Vector2(0, 0)
	difficulty_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(difficulty_bar)
	modulate.a = 0.0; scale = Vector2(0.85, 0.85)
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, 0.35).set_delay(delay_time)
	tw.tween_property(self, "scale", Vector2.ONE, 0.35).set_delay(delay_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_hover():
	if disabled: return
	create_tween().tween_property(self, "scale", Vector2(1.04, 1.04), 0.1).set_trans(Tween.TRANS_SINE)
	EventBus.play_sfx.emit("hover")

func _on_unhover():
	if disabled: return
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SINE)

func _on_pressed():
	disabled = true
	EventBus.play_sfx.emit("click")
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(0.92, 0.92), 0.08)
	tw.tween_property(self, "scale", Vector2(1.05, 1.05), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.1)
	EventBus.choice_made.emit(choice_index)
