extends Control

var ChoiceCardScene = preload("res://scenes/components/ChoiceCard.tscn")
var InventoryPanelClass = preload("res://scenes/ui/sub_panels/InventoryPanel.gd")
var RosterPanelClass = preload("res://scenes/ui/sub_panels/RosterPanel.gd")
var GalleryPanelClass = preload("res://scenes/ui/sub_panels/GalleryPanel.gd")

var main_container: VBoxContainer
var stats_container: HFlowContainer 
var event_label: RichTextLabel
var choices_container: VBoxContainer
var scroll_container: ScrollContainer

var panel_inventory: Control
var panel_roster: Control
var panel_gallery: Control
var is_typing = false
var current_node_sliders = {} 

# --- Death Panel UI ---
var death_panel: Panel
var death_bio_label: RichTextLabel
var upload_status_lbl: Label
var _cached_epic_ending: String = ""
var _is_uploading: bool = false

# --- CG Video Player System ---
var cg_overlay: ColorRect
var cg_player: VideoStreamPlayer
var _bgm_bus_idx: int = 0
var _bgm_old_vol: float = 0.0

var stat_tooltips = {
	"hp": "Health Points (HP).\nIf this reaches 0, you will die.",
	"constitution": "Constitution.\nRepresents physical health, stamina, and resistance to diseases or physical damage.",
	"intelligence": "Intelligence.\nRepresents learning speed, logical reasoning, and magical comprehension.",
	"charisma": "Charisma.\nRepresents physical attractiveness, charm, and presence.",
	"wealth": "Wealth.\nRepresents financial resources, family background, and material assets.",
	"luck": "Luck.\nRepresents destiny, karmic fortune, and the probability of encountering miracles.",
	"social": "Social.\nRepresents emotional intelligence, connections, and manipulation skills.",
	"willpower": "Willpower.\nRepresents mental fortitude, determination, and resistance to mental corruption."
}

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_find_bgm_bus()
	_build_ui()
	_init_sub_panels()
	EventBus.event_generated.connect(render_new_event)
	EventBus.game_state_updated.connect(update_stats_ui)
	EventBus.choice_made.connect(_on_any_choice_made)

# Dynamically locate the background music bus to mute it during CG playback
func _find_bgm_bus():
	_bgm_bus_idx = AudioServer.get_bus_index("Master") 
	for bus_name in ["BGM", "Music", "Background"]:
		var idx = AudioServer.get_bus_index(bus_name)
		if idx != -1:
			_bgm_bus_idx = idx
			break

func _build_ui():
	# 1. Main Background
	var bg = ColorRect.new(); bg.color = Color(0.08, 0.08, 0.08, 1.0); bg.set_anchors_preset(Control.PRESET_FULL_RECT); add_child(bg)
	main_container = VBoxContainer.new(); main_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_container.set_offset(SIDE_LEFT, 20); main_container.set_offset(SIDE_TOP, 20); main_container.set_offset(SIDE_RIGHT, -20); main_container.set_offset(SIDE_BOTTOM, -20)
	main_container.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(main_container)
	
	# 2. Top Navigation Bar
	var top_bar = HBoxContainer.new(); top_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL; top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE; main_container.add_child(top_bar)
	
	stats_container = HFlowContainer.new()
	stats_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL; stats_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	stats_container.add_theme_constant_override("h_separation", 15); stats_container.add_theme_constant_override("v_separation", 5)
	stats_container.mouse_filter = Control.MOUSE_FILTER_IGNORE; top_bar.add_child(stats_container)
	
	var btn_vbox = VBoxContainer.new(); btn_vbox.alignment = BoxContainer.ALIGNMENT_CENTER; btn_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE; top_bar.add_child(btn_vbox)
	var hbox_btns = HBoxContainer.new(); hbox_btns.add_theme_constant_override("separation", 10); hbox_btns.mouse_filter = Control.MOUSE_FILTER_IGNORE; btn_vbox.add_child(hbox_btns)
	
	var btn_inv = Button.new(); btn_inv.text = "🎒 Inventory"; btn_inv.custom_minimum_size = Vector2(110, 45); btn_inv.pressed.connect(_on_inv_pressed)
	var btn_ros = Button.new(); btn_ros.text = "👥 Roster"; btn_ros.custom_minimum_size = Vector2(100, 45); btn_ros.pressed.connect(_on_ros_pressed)
	var btn_gal = Button.new(); btn_gal.text = "🏆 Hall of Fame"; btn_gal.custom_minimum_size = Vector2(130, 45); btn_gal.pressed.connect(_on_gal_pressed)
	
	btn_inv.mouse_filter = Control.MOUSE_FILTER_STOP; btn_ros.mouse_filter = Control.MOUSE_FILTER_STOP; btn_gal.mouse_filter = Control.MOUSE_FILTER_STOP
	hbox_btns.add_child(btn_inv); hbox_btns.add_child(btn_ros); hbox_btns.add_child(btn_gal)
	
	var separator = ColorRect.new(); separator.custom_minimum_size = Vector2(0, 2); separator.color = Color(0.3, 0.3, 0.3, 0.5); separator.mouse_filter = Control.MOUSE_FILTER_IGNORE; main_container.add_child(separator)
	
	# 3. Scrolling Event Area
	scroll_container = ScrollContainer.new(); scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL; scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED; main_container.add_child(scroll_container)
	var scroll_vbox = VBoxContainer.new(); scroll_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL; scroll_vbox.add_theme_constant_override("separation", 20); scroll_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE; scroll_container.add_child(scroll_vbox)
	
	event_label = RichTextLabel.new(); event_label.bbcode_enabled = true; event_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL; event_label.fit_content = true; event_label.add_theme_font_size_override("normal_font_size", 22); event_label.mouse_filter = Control.MOUSE_FILTER_IGNORE; scroll_vbox.add_child(event_label)
	choices_container = VBoxContainer.new(); choices_container.add_theme_constant_override("separation", 15); choices_container.mouse_filter = Control.MOUSE_FILTER_IGNORE; scroll_vbox.add_child(choices_container)

	# --- Death & Upload Panel ---
	death_panel = Panel.new(); death_panel.set_anchors_preset(Control.PRESET_FULL_RECT); death_panel.self_modulate = Color(0.05, 0.05, 0.05, 0.98); death_panel.mouse_filter = Control.MOUSE_FILTER_STOP; death_panel.hide(); add_child(death_panel)
	var dv = VBoxContainer.new(); dv.set_anchors_preset(Control.PRESET_FULL_RECT); dv.set_offset(SIDE_LEFT, 60); dv.set_offset(SIDE_TOP, 60); dv.set_offset(SIDE_RIGHT, -60); dv.set_offset(SIDE_BOTTOM, -60); dv.alignment = BoxContainer.ALIGNMENT_CENTER; dv.add_theme_constant_override("separation", 25); death_panel.add_child(dv)
	var dt = Label.new(); dt.text = "【 A Legend Concludes 】"; dt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; dt.add_theme_font_size_override("font_size", 36); dt.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2)); dv.add_child(dt)
	var ds = ScrollContainer.new(); ds.size_flags_vertical = Control.SIZE_EXPAND_FILL; ds.custom_minimum_size = Vector2(0, 300)
	var bio_bg = PanelContainer.new(); bio_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL; var bstyle = StyleBoxFlat.new(); bstyle.bg_color = Color(0.1, 0.1, 0.15, 0.8); bstyle.set_border_width_all(2); bstyle.border_color = Color(0.4, 0.4, 0.5, 0.5); bstyle.set_content_margin_all(30); bio_bg.add_theme_stylebox_override("panel", bstyle); ds.add_child(bio_bg)
	death_bio_label = RichTextLabel.new(); death_bio_label.bbcode_enabled = true; death_bio_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL; death_bio_label.fit_content = true; death_bio_label.add_theme_font_size_override("normal_font_size", 18); bio_bg.add_child(death_bio_label); dv.add_child(ds)
	upload_status_lbl = Label.new(); upload_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; upload_status_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8)); upload_status_lbl.text = "Would you like to engrave this life into the Hall of Fame for others to witness?"; dv.add_child(upload_status_lbl)
	var db_hbox = HBoxContainer.new(); db_hbox.alignment = BoxContainer.ALIGNMENT_CENTER; db_hbox.add_theme_constant_override("separation", 40); dv.add_child(db_hbox)
	var up_btn = Button.new(); up_btn.text = "📜 Upload to Hall of Fame"; up_btn.custom_minimum_size = Vector2(300, 55); up_btn.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2)); up_btn.add_theme_font_size_override("font_size", 18); up_btn.pressed.connect(_on_upload_pressed); db_hbox.add_child(up_btn)
	var skip_btn = Button.new(); skip_btn.text = "💨 Fade into Obscurity (Menu)"; skip_btn.custom_minimum_size = Vector2(300, 55); skip_btn.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6)); skip_btn.add_theme_font_size_override("font_size", 18); skip_btn.pressed.connect(func(): EventBus.play_sfx.emit("click"); get_tree().reload_current_scene()); db_hbox.add_child(skip_btn)

	# --- Fullscreen CG Video Layer ---
	cg_overlay = ColorRect.new()
	cg_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	cg_overlay.color = Color(0, 0, 0, 1) # Pitch black to hide UI seamlessly
	cg_overlay.z_index = 200 # Render over everything
	cg_overlay.hide()
	add_child(cg_overlay)
	
	cg_player = VideoStreamPlayer.new()
	cg_player.set_anchors_preset(Control.PRESET_FULL_RECT)
	cg_player.expand = true # Keep aspect ratio and fill screen
	cg_overlay.add_child(cg_player)

func _init_sub_panels():
	panel_inventory = InventoryPanelClass.new(); panel_roster = RosterPanelClass.new(); panel_gallery = GalleryPanelClass.new()
	add_child(panel_inventory); add_child(panel_roster); add_child(panel_gallery)

func _on_inv_pressed(): EventBus.play_sfx.emit("click"); if panel_inventory: panel_inventory.open_panel()
func _on_ros_pressed(): EventBus.play_sfx.emit("click"); if panel_roster: panel_roster.open_panel()
func _on_gal_pressed(): EventBus.play_sfx.emit("click"); if panel_gallery: panel_gallery.open_panel()

func update_stats_ui(state: Dictionary):
	var stats = state.get("stats", {})
	for c in stats_container.get_children(): c.queue_free()
	var prefix = Label.new(); prefix.text = "Stats >>"; prefix.add_theme_color_override("font_color", Color(0, 1, 1)); prefix.mouse_filter = Control.MOUSE_FILTER_IGNORE; stats_container.add_child(prefix)
	for key in stats.keys():
		var panel = PanelContainer.new()
		var style = StyleBoxEmpty.new()
		panel.add_theme_stylebox_override("panel", style); panel.mouse_filter = Control.MOUSE_FILTER_STOP; panel.tooltip_text = stat_tooltips.get(key.to_lower(), "Attribute: " + key)
		var lbl = Label.new(); lbl.text = key.capitalize() + ": " + str(stats[key]); lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE 
		if key.to_lower() == "hp": lbl.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
		panel.add_child(lbl); stats_container.add_child(panel)
		var sep = Label.new(); sep.text = "|"; sep.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4)); sep.mouse_filter = Control.MOUSE_FILTER_IGNORE; stats_container.add_child(sep)

func render_new_event(event_data: Dictionary):
	for child in choices_container.get_children(): child.queue_free()
	var age = 1; if "current_age" in GameManager: age = GameManager.current_age
	var display_text = ""
	
	if event_data.get("type") == "node":
		EventBus.screen_shake_requested.emit(8.0, 1.0)
		display_text = "[color=#ff3333]【Life & Death Tribulation - Age " + str(age) + "】[/color]\n\n" + event_data.get("event_description", "")
		await typewrite_text(display_text)
		_build_node_boss_ui()
	else:
		display_text = "[color=#ffd700]【Age " + str(age) + "】[/color]\n\n" + event_data.get("event_description", "")
		await typewrite_text(display_text)
		if event_data.has("choices"):
			for i in range(event_data["choices"].size()):
				var card = ChoiceCardScene.instantiate(); choices_container.add_child(card); card.setup(i, event_data["choices"][i], i * 0.15) 
	_auto_scroll()

func _build_node_boss_ui():
	current_node_sliders.clear()
	var warning_lbl = Label.new(); warning_lbl.text = "⚠️ Tribulation descends. You must sacrifice your foundation to overcome this crisis. The more you sacrifice, the higher your chance to defy heaven. Stats are deducted immediately upon sacrifice!"; warning_lbl.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4)); warning_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; choices_container.add_child(warning_lbl)
	var grid = GridContainer.new(); grid.columns = 3; grid.add_theme_constant_override("h_separation", 15); choices_container.add_child(grid)
	
	var current_stats = {}; if "current_stats" in GameManager: current_stats = GameManager.current_stats
	var valid_keys = ["constitution", "intelligence", "charisma", "wealth", "luck", "social", "willpower"]
	
	for k in valid_keys:
		if not current_stats.has(k): continue
		var max_val = int(current_stats[k])
		var lbl = Label.new(); lbl.text = k.capitalize() + " (Max " + str(max_val) + ")"; lbl.custom_minimum_size = Vector2(140, 40); lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var slider = HSlider.new(); slider.max_value = max_val; slider.custom_minimum_size = Vector2(200, 40); slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var val_lbl = Label.new(); val_lbl.text = " 0"; val_lbl.custom_minimum_size = Vector2(40, 40); val_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slider.value_changed.connect(func(v): val_lbl.text = " " + str(v); EventBus.play_sfx.emit("hover")); current_node_sliders[k] = slider
		grid.add_child(lbl); grid.add_child(slider); grid.add_child(val_lbl)
		
	var submit_btn = Button.new(); submit_btn.text = "⚔️ Defy the Heavens!"; submit_btn.custom_minimum_size = Vector2(0, 60); submit_btn.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2)); submit_btn.add_theme_font_size_override("font_size", 24); submit_btn.pressed.connect(_on_node_submit); choices_container.add_child(submit_btn)

func _on_node_submit():
	EventBus.play_sfx.emit("click")
	var investments = {}
	for k in current_node_sliders.keys():
		var val = int(current_node_sliders[k].value)
		if val > 0: investments[k] = val
	for child in choices_container.get_children():
		if child is Control: child.modulate.a = 0.5; child.mouse_filter = Control.MOUSE_FILTER_IGNORE
	EventBus.node_investment_made.emit(investments)

func animate_dice_roll(base: int, difficulty: int, final_roll: int):
	event_label.visible_characters = -1
	var base_msg = "\n\n[color=#00ffff]🎲 The Wheel of Fate is turning...[/color]\n\n"
	var original_text = event_label.text
	var roll_steps = 25
	for i in range(roll_steps):
		if not is_inside_tree(): return 
		var fake_roll = randi() % 40 + 1
		var display_text = original_text + base_msg + "Base [" + str(base) + "] + Dice [[b][color=#ffff00][wave amp=50 freq=10]" + str(fake_roll) + "[/wave][/color][/b]] = " + str(base + fake_roll) + "  vs  DC " + str(difficulty)
		event_label.text = display_text; _auto_scroll()
		if i % 2 == 0 or i > 15: EventBus.play_sfx.emit("type") 
		var delay = lerp(0.015, 0.25, float(i) / float(roll_steps))
		await get_tree().create_timer(delay).timeout
		
	var suspense_text = original_text + base_msg + "Base [" + str(base) + "] + Dice [[b][color=#ff8800][shake rate=20 level=5]...[/shake][/color][/b]] = ???  vs  DC " + str(difficulty)
	event_label.text = suspense_text; _auto_scroll()
	await get_tree().create_timer(0.8).timeout 
	
	var is_succ = (base + final_roll) >= difficulty
	var color = "#00ff00" if is_succ else "#ff2222"
	var effect_open = "[shake rate=10 level=5]" if is_succ else "[tornado radius=5 freq=4]"
	var effect_close = "[/shake]" if is_succ else "[/tornado]"
	
	EventBus.screen_shake_requested.emit(8.0 if is_succ else 15.0, 0.4)
	EventBus.play_sfx.emit("success" if is_succ else "fail")
	event_label.text = original_text + base_msg + "Base [" + str(base) + "] + Dice [[b][color=" + color + "]" + effect_open + str(final_roll) + effect_close + "[/color][/b]] = " + str(base + final_roll) + "  vs  DC " + str(difficulty)
	_auto_scroll()
	await get_tree().create_timer(1.0).timeout

func animate_node_clash():
	event_label.visible_characters = -1; EventBus.play_sfx.emit("dice")
	var base_msg = "\n\n[color=#ff0000]⚡ The heavens rage, obliterating your foundation...[/color]\n\n"; var original_text = event_label.text
	var clash_steps = 15
	for i in range(clash_steps):
		if not is_inside_tree(): return
		EventBus.screen_shake_requested.emit(lerp(2.0, 10.0, float(i) / float(clash_steps)), 0.15)
		if i % 3 == 0: EventBus.play_sfx.emit("fail") 
		var chaos_str = ""; var chars = ["▓", "▒", "░", "█", "▄", "▀"]
		for j in range(20): chaos_str += chars[randi() % chars.size()]
		event_label.text = original_text + base_msg + "[center][color=#ffaa00][shake rate=30 level=15]" + chaos_str + "[/shake][/color][/center]"
		_auto_scroll(); await get_tree().create_timer(lerp(0.1, 0.3, float(i) / float(clash_steps))).timeout
	event_label.text = original_text + base_msg + "[center][color=#444444]... silence falls ...[/color][/center]"; _auto_scroll()
	await get_tree().create_timer(1.2).timeout
	event_label.text = original_text + "\n\n[color=#ff0000]⚡ The clouds disperse. The verdict is sealed...[/color]"; _auto_scroll()
	await get_tree().create_timer(0.5).timeout

# =========================================================
# Handle outcome, check for CG, and display text
# =========================================================
func play_outcome(outcome_data: Dictionary, is_node: bool = false):
	event_label.visible_characters = -1
	
	# 1. Intercept CG play commands first
	var cg_filename = outcome_data.get("cg_play", "")
	if cg_filename != "":
		await _play_cg_video(cg_filename)

	# 2. Proceed with normal text resolution
	var outcome_msg = "\n\n"
	if is_node: outcome_msg += "[color=#" + ("ff4444" if outcome_data.get("is_dead", false) else "00ff00") + "]【Tribulation Verdict】[/color]\n"
	outcome_msg += outcome_data.get("outcome_text", "Time flows silently.")
	
	var severe_damage = false
	for stat_name in outcome_data.get("stat_changes", {}).keys():
		var val = outcome_data["stat_changes"][stat_name]
		if val != 0:
			EventBus.spawn_floating_text.emit(stat_name.capitalize() + (" +" if val > 0 else " ") + str(val), val > 0)
			if stat_name == "hp" and val < 0: severe_damage = true
			
	if severe_damage or outcome_data.get("is_dead", false): EventBus.screen_shake_requested.emit(18.0, 0.8)
	await typewrite_append(outcome_msg)
	await get_tree().create_timer(3.5).timeout

# Core video playback logic - Now using VideoStreamTheora
func _play_cg_video(filename: String):
	# Force extension to .ogv to avoid Godot 4 WebM constraints
	filename = filename.replace(".webm", ".ogv").replace(".mp4", ".ogv")
	
	var world_key = "modern_city"
	if "world_key" in GameManager: world_key = GameManager.world_key
	
	# Check for external mod files first, then internal assets
	var path = "user://mods/" + world_key + "/cgs/" + filename
	if not FileAccess.file_exists(path):
		path = "res://mods/" + world_key + "/cgs/" + filename
	if not FileAccess.file_exists(path):
		path = "res://assets/video/childern_happy.ogv"	
	if not FileAccess.file_exists(path):
		push_warning("⚠️ CG Video not found. Make sure it's an .ogv file located at: " + path)
		return 
		
	# Load Ogg Theora stream
	var stream = VideoStreamTheora.new()
	stream.file = path
	cg_player.stream = stream
	
	# 1. Crossfade BGM to mute (-80dB)
	_bgm_old_vol = AudioServer.get_bus_volume_db(_bgm_bus_idx)
	var tw_audio = create_tween()
	tw_audio.tween_method(func(v): AudioServer.set_bus_volume_db(_bgm_bus_idx, v), _bgm_old_vol, -80.0, 0.5)
	
	# 2. Fade in cinematic black overlay
	cg_overlay.modulate.a = 0
	cg_overlay.show()
	var tw_fade_in = create_tween()
	tw_fade_in.tween_property(cg_overlay, "modulate:a", 1.0, 0.5)
	await tw_fade_in.finished
	
	# 3. Play video and wait
	cg_player.play()
	await cg_player.finished
	
	# 4. Fade out overlay
	var tw_fade_out = create_tween()
	tw_fade_out.tween_property(cg_overlay, "modulate:a", 0.0, 0.5)
	await tw_fade_out.finished
	cg_overlay.hide()
	
	# 5. Restore BGM volume
	var tw_audio_in = create_tween()
	tw_audio_in.tween_method(func(v): AudioServer.set_bus_volume_db(_bgm_bus_idx, v), -80.0, _bgm_old_vol, 0.5)

# =========================================================

func show_thinking(): event_label.visible_characters = -1; event_label.text += "\n[color=#888888]( The Heavens are deducing the karma of this event... )[/color]"; _auto_scroll()
func hide_thinking(): event_label.visible_characters = -1; event_label.text = event_label.text.replace("\n[color=#888888]( The Heavens are deducing the karma of this event... )[/color]", "")
func typewrite_text(text: String):
	is_typing = true; event_label.text = text; var total_chars = event_label.get_parsed_text().length(); event_label.visible_characters = 0
	for i in range(total_chars):
		if not is_inside_tree(): break 
		event_label.visible_characters += 1; _auto_scroll()
		if i % 3 == 0: EventBus.play_sfx.emit("type")
		await get_tree().create_timer(0.02).timeout
	event_label.visible_characters = -1; is_typing = false
func typewrite_append(new_text: String):
	is_typing = true; event_label.visible_characters = -1
	var old_length = event_label.get_parsed_text().length(); event_label.text += new_text; var new_length = event_label.get_parsed_text().length()
	event_label.visible_characters = old_length
	for i in range(new_length - old_length):
		if not is_inside_tree(): break 
		event_label.visible_characters += 1; _auto_scroll()
		if i % 3 == 0: EventBus.play_sfx.emit("type")
		await get_tree().create_timer(0.02).timeout
	event_label.visible_characters = -1; is_typing = false
func _auto_scroll(): await get_tree().process_frame; if scroll_container: scroll_container.scroll_vertical = int(scroll_container.get_v_scroll_bar().max_value)
func _on_any_choice_made(_idx: int): for child in choices_container.get_children(): if child is Button: child.disabled = true; create_tween().tween_property(child, "modulate:a", 0.4, 0.2)

func show_death_panel(epic, age, cause):
	var safe_epic = str(epic) if epic != null else "A life forgotten by time, lost in the void of the Akashic Records..."
	var safe_cause = str(cause) if cause != null else "Unknown fate"
	var safe_age = str(age) if age != null else "0"
	_cached_epic_ending = safe_epic
	death_bio_label.text = "[center][b]Final Age: " + safe_age + " | Cause: " + safe_cause + "[/b][/center]\n\n" + safe_epic
	death_panel.modulate.a = 0; death_panel.show(); create_tween().tween_property(death_panel, "modulate:a", 1.0, 1.0)

func _on_upload_pressed():
	if _is_uploading: return
	_is_uploading = true; EventBus.play_sfx.emit("click")
	upload_status_lbl.text = "Uploading your legend to the Heavens..."; upload_status_lbl.add_theme_color_override("font_color", Color(1.0, 1.0, 0.2))
	var res = await NetworkManager.submit_leaderboard(_cached_epic_ending)
	if res.has("error"): upload_status_lbl.text = "Upload failed. The heavens rejected your connection."; upload_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2)); _is_uploading = false
	else: upload_status_lbl.text = "Legend engraved! Returning to menu..."; upload_status_lbl.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2)); await get_tree().create_timer(2.0).timeout; get_tree().reload_current_scene()
