extends Node2D

@onready var ui_layer = get_node_or_null("UILayer")
@onready var overlay_layer = get_node_or_null("OverlayLayer")
@onready var camera = get_node_or_null("Camera2D")

var menu_ui: Control; var game_ui: Control; var vfx_sys: Control; var loading_ui: Control
var shake_tween: Tween; var _is_first_event: bool = true

@export_group("Audio - BGM")
@export var bgm_menu: AudioStream; @export var bgm_stages: Array[AudioStream]; @export var bgm_epic: AudioStream             
@export_group("Audio - SFX")
@export var sfx_hover: AudioStream; @export var sfx_click: AudioStream; @export var sfx_type: AudioStream; @export var sfx_dice: AudioStream             
@export var sfx_roll_success: AudioStream; @export var sfx_roll_fail: AudioStream; @export var sfx_outcome_good: AudioStream; @export var sfx_outcome_bad: AudioStream      

var birth_texts = {
	"modern_city": "A cry breaks the silence of the delivery room, a new life is born...",
	"xianxia": "In the chaos, a soul crosses Samsara and is about to enter the mortal world...",
	"medieval_war": "In the chaotic world filled the smoke of war, another life is born...",
}

func _ready():
	_ensure_core_nodes_exist(); _init_sub_scenes(); _connect_event_bus()
	if menu_ui: menu_ui.show()
	if game_ui: game_ui.hide()
	if AudioManager and bgm_menu: AudioManager.crossfade_bgm(bgm_menu)

func _ensure_core_nodes_exist():
	if not ui_layer: ui_layer = CanvasLayer.new(); ui_layer.name = "UILayer"; add_child(ui_layer)
	if not overlay_layer: overlay_layer = CanvasLayer.new(); overlay_layer.name = "OverlayLayer"; overlay_layer.layer = 10; add_child(overlay_layer)
	if not camera: camera = Camera2D.new(); camera.name = "Camera2D"; camera.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT; add_child(camera)

func _init_sub_scenes():
	if ResourceLoader.exists("res://scenes/ui/MenuUI.tscn"): menu_ui = load("res://scenes/ui/MenuUI.tscn").instantiate(); ui_layer.add_child(menu_ui)
	if ResourceLoader.exists("res://scenes/ui/GameUI.tscn"): game_ui = load("res://scenes/ui/GameUI.tscn").instantiate(); ui_layer.add_child(game_ui)
	if ResourceLoader.exists("res://scenes/systems/VFXSystem.tscn"): vfx_sys = load("res://scenes/systems/VFXSystem.tscn").instantiate(); overlay_layer.add_child(vfx_sys)
	if ResourceLoader.exists("res://scenes/ui/LoadingUI.tscn"): loading_ui = load("res://scenes/ui/LoadingUI.tscn").instantiate(); overlay_layer.add_child(loading_ui)
	if ResourceLoader.exists("res://scenes/systems/ThemeSystem.tscn"): add_child(load("res://scenes/systems/ThemeSystem.tscn").instantiate())

func _connect_event_bus():
	EventBus.game_start_requested.connect(_on_game_start); EventBus.choice_made.connect(_on_choice_made)
	EventBus.node_investment_made.connect(_on_node_investment); EventBus.screen_shake_requested.connect(_on_shake)
	EventBus.game_over.connect(_on_game_over); EventBus.play_sfx.connect(_on_sfx); EventBus.bgm_stage_changed.connect(_on_bgm_stage)

func _on_sfx(n: String):
	if not AudioManager: return
	match n:
		"hover": AudioManager.play_sfx(sfx_hover); 
		"click": AudioManager.play_sfx(sfx_click)
		"type": AudioManager.play_type_sound(sfx_type); 
		"dice": AudioManager.play_sfx(sfx_dice)
		"success": AudioManager.play_sfx(sfx_roll_success); 
		"fail": AudioManager.play_sfx(sfx_roll_fail)
		"good": AudioManager.play_sfx(sfx_outcome_good); 
		"bad": AudioManager.play_sfx(sfx_outcome_bad)

func _on_bgm_stage(age: int):
	if bgm_stages.is_empty() or not AudioManager: return
	var t = 0
	if age <= 6: t = 0 
	elif age <= 15: t = 1 
	elif age <= 25: t = 2 
	elif age <= 40: t = 3 
	elif age <= 55: t = 4 
	elif age <= 70: t = 5 
	elif age <= 85: t = 6 
	else: t = 7
	t = clampi(t, 0, bgm_stages.size() - 1)
	if bgm_stages[t]: AudioManager.crossfade_bgm(bgm_stages[t])

var _narrative_ready: bool = false; var _narrative_data: Dictionary = {}

func _on_game_start(w, c, g, d, s):
	_is_first_event = true
	EventBus.ui_show_loading.emit("The gods are reshaping your body...")
	var res = await NetworkManager.start_game(w, c, g, d, s)
	if res.has("error"): EventBus.ui_hide_loading.emit(); push_error("Creation failed: " + str(res)); return
	if menu_ui: 
		if menu_ui.has_method("hide_menu"): menu_ui.hide_menu()
		else: menu_ui.hide()
	if game_ui: game_ui.show(); game_ui.modulate.a = 0.0; create_tween().tween_property(game_ui, "modulate:a", 1.0, 0.5)
	_on_bgm_stage(1)
	fetch_next_event(w)

func fetch_next_event(world_key: String = ""):
	if _is_first_event and world_key != "":
		EventBus.ui_show_loading.emit(birth_texts.get(world_key, "A new life begins in an unknown world..."))
		_is_first_event = false
	else:
		EventBus.ui_show_loading.emit("Time flows, destiny continues...")
		
	var state = await NetworkManager.get_state()
	if state.has("error"): EventBus.ui_hide_loading.emit(); return
		
	GameManager.current_stats = state.get("stats", {})
	GameManager.current_age = state.get("age", 1) 
	EventBus.game_state_updated.emit(state)
	
	if state.get("is_dead", false): EventBus.ui_hide_loading.emit(); return 
	var event_data = await NetworkManager.generate_event()
	EventBus.ui_hide_loading.emit()
	if not event_data.has("error"): EventBus.event_generated.emit(event_data)

func _on_choice_made(index: int):
	EventBus.play_sfx.emit("click")
	var roll_res = await NetworkManager.roll_dice(index)
	if roll_res.has("error"): return
	_fetch_narrative_bg(false)
	if game_ui and game_ui.has_method("animate_dice_roll"): await game_ui.animate_dice_roll(roll_res.get("base", 0), roll_res.get("difficulty", 40), roll_res.get("roll", 0))
	if not _narrative_ready and game_ui and game_ui.has_method("show_thinking"): game_ui.show_thinking()
	while not _narrative_ready: await get_tree().process_frame
	if game_ui and game_ui.has_method("hide_thinking"): game_ui.hide_thinking()
	if game_ui and game_ui.has_method("play_outcome"): await game_ui.play_outcome(_narrative_data, false)
		
	if _narrative_data.get("is_dead", false):
		var state = await NetworkManager.get_state()
		EventBus.game_over.emit(_narrative_data.get("epic_ending", "An ordinary life."), state.get("age", 0), state.get("cause_of_death", "Unknown"))
	else:
		fetch_next_event()

func _on_node_investment(investments: Dictionary):
	EventBus.play_sfx.emit("click")
	var res = await NetworkManager.submit_node_choice(investments)
	if res.has("error"): return
	var state = await NetworkManager.get_state()
	EventBus.game_state_updated.emit(state)
	_fetch_narrative_bg(true)
	if game_ui and game_ui.has_method("animate_node_clash"): await game_ui.animate_node_clash()
	if not _narrative_ready and game_ui and game_ui.has_method("show_thinking"): game_ui.show_thinking()
	while not _narrative_ready: await get_tree().process_frame
	if game_ui and game_ui.has_method("hide_thinking"): game_ui.hide_thinking()
	if game_ui and game_ui.has_method("play_outcome"): await game_ui.play_outcome(_narrative_data, true)
	
	if _narrative_data.get("is_dead", false):
		state = await NetworkManager.get_state()
		EventBus.game_over.emit(_narrative_data.get("epic_ending", "Turned to dust in the Great Tribulation."), state.get("age", 0), state.get("cause_of_death", "Fell in Tribulation"))
	else:
		fetch_next_event()

func _fetch_narrative_bg(is_node: bool):
	_narrative_ready = false
	var res = {}
	if is_node: res = await NetworkManager.resolve_node_narrative()
	else: res = await NetworkManager.resolve_narrative()
	_narrative_data = res
	_narrative_ready = true

func _on_shake(i: float, d: float):
	if not camera: return
	if shake_tween and shake_tween.is_valid(): shake_tween.kill()
	shake_tween = create_tween()
	for step in range(int(d / 0.05)): shake_tween.tween_property(camera, "offset", Vector2(randf_range(-i, i), randf_range(-i, i)), 0.05)
	shake_tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)

func _on_game_over(epic, age, cause):
	if AudioManager and bgm_epic: 
		AudioManager.crossfade_bgm(bgm_epic)
		
	if game_ui:
		create_tween().tween_property(game_ui.main_container, "modulate:a", 0.0, 1.5)
		await get_tree().create_timer(1.5).timeout
		if game_ui.has_method("show_death_panel"):
			game_ui.show_death_panel(epic, age, cause)
	
	if vfx_sys and vfx_sys.has_method("play_epic_ending_cinematic"): 
		vfx_sys.play_epic_ending_cinematic(epic, age, cause)
