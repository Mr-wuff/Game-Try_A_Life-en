extends Node

var world_name: String = "Unknown World"
var world_key: String = ""
var char_name: String = "Traveler"
var current_age: int = 1
var current_stats: Dictionary = {}
var is_dead: bool = false
var cause_of_death: String = ""

var inventory: Array = []
var causal_tags: Array = []

# World config cache from backend
var loading_texts: Dictionary = {}
var age_headers: Dictionary = {}
var stat_descriptions: Dictionary = {}

func _ready():
	EventBus.game_state_updated.connect(_on_state_updated)
	EventBus.game_start_requested.connect(_on_game_start)

func _on_game_start(w_key: String, c_name: String, _g: String, _d: String, _s: Dictionary):
	world_key = w_key; char_name = c_name
	loading_texts = {}; age_headers = {}; stat_descriptions = {}

func _on_state_updated(state: Dictionary):
	if state.has("world_name"): world_name = state["world_name"]
	if state.has("character_name"): char_name = state["character_name"]
	if state.has("age"): current_age = state["age"]
	if state.has("stats"): current_stats = state["stats"]
	if state.has("is_dead"): is_dead = state["is_dead"]
	if state.has("cause_of_death"): cause_of_death = state["cause_of_death"]
	if state.has("inventory"): inventory = state["inventory"]
	if state.has("causal_tags"): causal_tags = state["causal_tags"]
	if state.has("loading_texts"): loading_texts = state["loading_texts"]
	if state.has("age_headers"): age_headers = state["age_headers"]
	if state.has("stat_descriptions"): stat_descriptions = state["stat_descriptions"]
	if current_stats.has("hp") and current_stats["hp"] <= 20 and not is_dead:
		EventBus.health_warning.emit()
