extends Control

var menu_panel: Panel
var stat_alloc_panel: Panel; var settings_panel: Panel
var model_setup_panel: Panel  
var name_input: LineEdit; var world_option: OptionButton;
var gender_option: OptionButton
var diff_option: OptionButton; var alloc_option: OptionButton
var stat_sliders = {}; var points_left_label: Label;
var max_manual_points = 140

var _model_catalog: Array = []
var _current_model: String = ""
var _model_list_container: VBoxContainer
var _model_status_label: Label
var _model_progress_bar: ProgressBar
var _model_progress_label: Label
var _pulling_model: String = ""
var _poll_timer: float = 0.0

var _settings_model_list: VBoxContainer
var _settings_model_status: Label

var api_url_input: LineEdit
var api_key_input: LineEdit
var api_model_input: LineEdit
var api_status_lbl: Label

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE;
	_build_ui()
	if stat_alloc_panel: stat_alloc_panel.hide()
	if settings_panel: settings_panel.hide()
	if model_setup_panel: model_setup_panel.hide()
	
	_check_first_launch.call_deferred()
	_auto_apply_saved_api.call_deferred()

func _process(delta):
	if _pulling_model != "":
		_poll_timer += delta
		if _poll_timer >= 0.5:
			_poll_timer = 0.0
			_poll_pull_progress()

func _check_first_launch():
	var status = await NetworkManager.get_model_status()
	if status.has("error"): return
	_current_model = status.get("current_model", "")
	var catalog = await NetworkManager.get_model_catalog()
	if catalog.has("error"): return
	var installed = catalog.get("installed", [])
	
	if installed.is_empty() and (api_status_lbl == null or api_status_lbl.text == ""):
		menu_panel.hide()
		_show_model_setup(catalog.get("catalog", []), true)
	else:
		_model_catalog = catalog.get("catalog", [])
		_current_model = catalog.get("current_model", "")

func hide_menu():
	var f = create_tween()
	if menu_panel: f.tween_property(menu_panel, "modulate:a", 0.0, 0.4)
	await f.finished
	if menu_panel: menu_panel.hide()
	if stat_alloc_panel: stat_alloc_panel.hide()
	if settings_panel: settings_panel.hide()
	if model_setup_panel: model_setup_panel.hide()
	self.hide()

func _row(label_text: String, ctrl: Control, grid: GridContainer) -> Control:
	var l = Label.new(); l.text = label_text;
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER; l.custom_minimum_size = Vector2(120, 40)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE; grid.add_child(l)
	ctrl.custom_minimum_size = Vector2(260, 40); ctrl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	grid.add_child(ctrl);
	return ctrl

func _build_ui():
	menu_panel = Panel.new();
	menu_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_panel.self_modulate = Color(0.1, 0.1, 0.1, 0.95); menu_panel.mouse_filter = Control.MOUSE_FILTER_STOP; add_child(menu_panel)
	var mv = VBoxContainer.new(); mv.set_anchors_preset(Control.PRESET_FULL_RECT)
	mv.alignment = BoxContainer.ALIGNMENT_CENTER; mv.add_theme_constant_override("separation", 25)
	mv.mouse_filter = Control.MOUSE_FILTER_IGNORE;
	menu_panel.add_child(mv)

	var t = Label.new(); t.text = "【 Try A Life 】"; t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 42); t.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3));
	mv.add_child(t)
	var tg = Label.new(); tg.text = "Every choice rewrites your destiny"; tg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tg.add_theme_font_size_override("font_size", 16); tg.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6));
	mv.add_child(tg)

	var fg = GridContainer.new(); fg.columns = 2; fg.add_theme_constant_override("h_separation", 20)
	fg.add_theme_constant_override("v_separation", 15); fg.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	fg.mouse_filter = Control.MOUSE_FILTER_IGNORE;
	mv.add_child(fg)
	name_input = _row("Your Name:", LineEdit.new(), fg) as LineEdit; name_input.placeholder_text = "Traveler"
	world_option = _row("World:", OptionButton.new(), fg) as OptionButton
	
	# 【核心修复】：将 Metadata 精准对齐后端 Python 的文件名
	world_option.add_item("Modern City"); world_option.set_item_metadata(0, "modern_city")
	world_option.add_item("Immortal Cultivation"); world_option.set_item_metadata(1, "xianxia")
	world_option.add_item("Medieval Warring States"); world_option.set_item_metadata(2, "medieval_war")
	
	gender_option = _row("Gender:", OptionButton.new(), fg) as OptionButton
	gender_option.add_item("Random"); gender_option.add_item("Male"); gender_option.add_item("Female")
	diff_option = _row("Difficulty:", OptionButton.new(), fg) as OptionButton
	diff_option.add_item("Normal"); diff_option.add_item("Easy"); diff_option.add_item("Hard"); diff_option.add_item("Nightmare")
	alloc_option = _row("Stat Allocation:", OptionButton.new(), fg) as OptionButton
	alloc_option.add_item("Random (150 pts)"); alloc_option.add_item("Manual (140 pts)")

	var model_hint = Label.new(); model_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	model_hint.add_theme_font_size_override("font_size", 13);
	model_hint.add_theme_color_override("font_color", Color(0.4, 0.6, 0.5))
	model_hint.text = "AI Model: (checking...)"; mv.add_child(model_hint)
	_model_status_label = model_hint

	var bv = VBoxContainer.new(); bv.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	bv.add_theme_constant_override("separation", 12);
	bv.mouse_filter = Control.MOUSE_FILTER_IGNORE; mv.add_child(bv)
	var sb = Button.new(); sb.text = "▶ Begin New Life"; sb.custom_minimum_size = Vector2(280, 60)
	sb.add_theme_font_size_override("font_size", 24);
	sb.add_theme_color_override("font_color", Color(0.2, 1, 0.2))
	sb.pressed.connect(_on_start); sb.mouse_entered.connect(func(): EventBus.play_sfx.emit("hover")); bv.add_child(sb)
	var stb = Button.new(); stb.text = "⚙ Settings";
	stb.custom_minimum_size = Vector2(280, 45)
	stb.pressed.connect(func(): EventBus.play_sfx.emit("click"); _open_settings())
	stb.mouse_entered.connect(func(): EventBus.play_sfx.emit("hover")); bv.add_child(stb)

	_build_settings_panel()
	_build_stat_alloc_panel()
	_build_model_setup_panel()
	_update_model_hint()

func _update_model_hint():
	if api_status_lbl and api_status_lbl.text.contains("Successfully"):
		_model_status_label.text = "AI Model: ☁ Cloud API"
		_model_status_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
		return
	var status = await NetworkManager.get_model_status()
	if status.has("error"):
		_model_status_label.text = "AI Model: ⚠ Backend not connected"
		_model_status_label.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
	else:
		_current_model = status.get("current_model", "unknown")
		_model_status_label.text = "AI Model: 🧠 " + _current_model
		_model_status_label.add_theme_color_override("font_color", Color(0.4, 0.8, 0.5))

func _build_settings_panel():
	settings_panel = Panel.new();
	settings_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	settings_panel.self_modulate = Color(0, 0, 0, 0.98); settings_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(settings_panel); settings_panel.hide()
	var sv = VBoxContainer.new(); sv.set_anchors_preset(Control.PRESET_FULL_RECT)
	sv.alignment = BoxContainer.ALIGNMENT_CENTER; sv.add_theme_constant_override("separation", 15)
	sv.mouse_filter = Control.MOUSE_FILTER_IGNORE;
	settings_panel.add_child(sv)
	var stl = Label.new(); stl.text = "Settings"; stl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stl.add_theme_font_size_override("font_size", 28); sv.add_child(stl)

	var vh = HBoxContainer.new(); vh.size_flags_horizontal = Control.SIZE_SHRINK_CENTER;
	vh.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var vl = Label.new(); vl.text = "Master Volume:"; vl.custom_minimum_size = Vector2(120, 0)
	var vs = HSlider.new();
	vs.custom_minimum_size = Vector2(200, 40); vs.max_value = 1.0; vs.step = 0.05; vs.value = 0.5
	vs.value_changed.connect(func(v): AudioServer.set_bus_volume_db(0, linear_to_db(float(v))))
	vh.add_child(vl); vh.add_child(vs);
	sv.add_child(vh)
	
	var mh = Label.new(); mh.text = "── Local AI Models ──"; mh.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mh.add_theme_font_size_override("font_size", 18);
	mh.add_theme_color_override("font_color", Color(1, 0.85, 0.3)); sv.add_child(mh)

	_settings_model_status = Label.new(); _settings_model_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_settings_model_status.add_theme_font_size_override("font_size", 14); sv.add_child(_settings_model_status)

	var scroll = ScrollContainer.new();
	scroll.custom_minimum_size = Vector2(500, 160) 
	scroll.size_flags_horizontal = Control.SIZE_SHRINK_CENTER; sv.add_child(scroll)
	_settings_model_list = VBoxContainer.new(); _settings_model_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_settings_model_list.add_theme_constant_override("separation", 8); scroll.add_child(_settings_model_list)

	var div = ColorRect.new(); div.custom_minimum_size = Vector2(450, 2); div.color = Color(0.3, 0.3, 0.3); div.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	sv.add_child(div)
	
	var ah = Label.new(); ah.text = "── Custom Cloud API ──"; ah.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ah.add_theme_font_size_override("font_size", 18); ah.add_theme_color_override("font_color", Color(0.3, 0.8, 1.0)); sv.add_child(ah)
	
	var api_desc = Label.new(); api_desc.text = "Fill to override local models with DeepSeek/OpenAI etc."; api_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	api_desc.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6)); api_desc.add_theme_font_size_override("font_size", 12); sv.add_child(api_desc)

	var create_input_row = func(label_text: String, placeholder: String, is_secret: bool = false):
		var hbox = HBoxContainer.new(); hbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		var lbl = Label.new(); lbl.text = label_text; lbl.custom_minimum_size = Vector2(100, 35); lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		var input = LineEdit.new(); input.custom_minimum_size = Vector2(250, 35); input.placeholder_text = placeholder; input.secret = is_secret
		hbox.add_child(lbl); hbox.add_child(input); sv.add_child(hbox)
		return input

	api_url_input = create_input_row.call("Base URL:", "https://api.deepseek.com/v1")
	api_model_input = create_input_row.call("Model:", "deepseek-chat")
	api_key_input = create_input_row.call("API Key:", "sk-...", true)
	
	api_status_lbl = Label.new(); api_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	api_status_lbl.add_theme_font_size_override("font_size", 14); sv.add_child(api_status_lbl)

	var btn_hbox = HBoxContainer.new(); btn_hbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER; btn_hbox.add_theme_constant_override("separation", 20); sv.add_child(btn_hbox)

	var apply_api_btn = Button.new(); apply_api_btn.text = "Apply Custom API"; apply_api_btn.custom_minimum_size = Vector2(180, 40)
	apply_api_btn.pressed.connect(_on_apply_api_pressed); btn_hbox.add_child(apply_api_btn)

	var csb = Button.new();
	csb.text = "Back to Menu"; csb.custom_minimum_size = Vector2(180, 40)
	csb.pressed.connect(func(): EventBus.play_sfx.emit("click"); settings_panel.hide(); _update_model_hint());
	btn_hbox.add_child(csb)

func _open_settings():
	settings_panel.show()
	_refresh_settings_models()

func _refresh_settings_models():
	for c in _settings_model_list.get_children(): c.queue_free()
	var catalog = await NetworkManager.get_model_catalog()
	if catalog.has("error"):
		_settings_model_status.text = "⚠ Cannot connect to backend"
		return
	_current_model = catalog.get("current_model", "")
	_model_catalog = catalog.get("catalog", [])
	
	if api_status_lbl.text.contains("Successfully"):
		_settings_model_status.text = "Local Model Skipped (Using Cloud API)"
	else:
		_settings_model_status.text = "Active Local: " + _current_model

	for m in _model_catalog:
		var row = _create_model_row(m, false)
		_settings_model_list.add_child(row)

func _auto_apply_saved_api():
	if Engine.has_singleton("SaveManager"):
		var sm = Engine.get_singleton("SaveManager")
		if "config" in sm and sm.config != null:
			api_url_input.text = sm.config.get_value("API", "BaseURL", "")
			api_model_input.text = sm.config.get_value("API", "ModelName", "")
			api_key_input.text = sm.config.get_value("API", "Key", "")
			
			if api_url_input.text != "" and api_model_input.text != "":
				var res = await NetworkManager.set_custom_api(api_url_input.text, api_key_input.text, api_model_input.text)
				if not res.has("error"):
					api_status_lbl.text = "Cloud API Applied Successfully!"
					api_status_lbl.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))

func _on_apply_api_pressed():
	EventBus.play_sfx.emit("click")
	var url = api_url_input.text.strip_edges()
	var key = api_key_input.text.strip_edges()
	var model = api_model_input.text.strip_edges()
	
	if url == "" or model == "":
		api_status_lbl.text = "URL and Model cannot be empty!"
		api_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
		return
		
	api_status_lbl.text = "Connecting..."
	api_status_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.2))
	
	if Engine.has_singleton("SaveManager"):
		var sm = Engine.get_singleton("SaveManager")
		sm.save_setting("API", "BaseURL", url)
		sm.save_setting("API", "ModelName", model)
		sm.save_setting("API", "Key", key)
		
	var res = await NetworkManager.set_custom_api(url, key, model)
	if res.has("error"):
		api_status_lbl.text = "Failed to switch API backend."
		api_status_lbl.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	else:
		api_status_lbl.text = "Cloud API Applied Successfully!"
		api_status_lbl.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
		_refresh_settings_models()

func _build_model_setup_panel():
	model_setup_panel = Panel.new();
	model_setup_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	model_setup_panel.self_modulate = Color(0.05, 0.05, 0.1, 0.99); model_setup_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(model_setup_panel); model_setup_panel.hide()

	var vb = VBoxContainer.new(); vb.set_anchors_preset(Control.PRESET_FULL_RECT)
	vb.set_offset(SIDE_LEFT, 40); vb.set_offset(SIDE_TOP, 30); vb.set_offset(SIDE_RIGHT, -40);
	vb.set_offset(SIDE_BOTTOM, -30)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER; vb.add_theme_constant_override("separation", 15); model_setup_panel.add_child(vb)

	var title = Label.new(); title.text = "🧠 AI Engine Setup"; title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32);
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.3)); vb.add_child(title)

	var desc = Label.new(); desc.text = "This game uses a local AI model to generate your life story.\nChoose a model to download. You can change this later in Settings."
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; desc.add_theme_font_size_override("font_size", 15)
	desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7)); desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; vb.add_child(desc)

	var scroll = ScrollContainer.new();
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 300); vb.add_child(scroll)
	_model_list_container = VBoxContainer.new(); _model_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_model_list_container.add_theme_constant_override("separation", 10); scroll.add_child(_model_list_container)

	_model_progress_label = Label.new();
	_model_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_model_progress_label.add_theme_font_size_override("font_size", 14); _model_progress_label.text = ""; vb.add_child(_model_progress_label)
	_model_progress_bar = ProgressBar.new(); _model_progress_bar.custom_minimum_size = Vector2(400, 25)
	_model_progress_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER; _model_progress_bar.visible = false;
	vb.add_child(_model_progress_bar)

	var skip = Button.new(); skip.text = "Skip (I'll configure later)"; skip.custom_minimum_size = Vector2(260, 40)
	skip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER;
	skip.add_theme_font_size_override("font_size", 13)
	skip.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	skip.pressed.connect(func(): model_setup_panel.hide(); menu_panel.show()); vb.add_child(skip)

func _show_model_setup(catalog: Array, is_first: bool):
	_model_catalog = catalog
	model_setup_panel.show()
	for c in _model_list_container.get_children(): c.queue_free()
	for m in catalog:
		var row = _create_model_row(m, is_first)
		_model_list_container.add_child(row)

func _create_model_row(m: Dictionary, is_setup: bool) -> PanelContainer:
	var pc = PanelContainer.new()
	var style = StyleBoxFlat.new()
	var is_active = m.get("id", "") == _current_model
	var is_installed = m.get("installed", false)

	if m.get("tier", "") == "recommended":
		style.bg_color = Color(0.1, 0.15, 0.1, 0.95)
		style.border_color = Color(0.3, 0.8, 0.3, 0.5)
	elif is_active:
		style.bg_color = Color(0.1, 0.1, 0.2, 0.95)
		style.border_color = Color(0.3, 0.5, 1.0, 0.5)
	else:
		style.bg_color = Color(0.08, 0.08, 0.1, 0.95)
		style.border_color = Color(0.2, 0.2, 0.3, 0.3)
	style.set_border_width_all(1);
	style.set_corner_radius_all(6); style.set_content_margin_all(12)
	pc.add_theme_stylebox_override("panel", style)

	var hb = HBoxContainer.new(); hb.add_theme_constant_override("separation", 15); pc.add_child(hb)

	var info = VBoxContainer.new(); info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 4);
	hb.add_child(info)

	var name_row = HBoxContainer.new(); name_row.add_theme_constant_override("separation", 8); info.add_child(name_row)
	var nl = Label.new(); nl.text = m.get("name", ""); nl.add_theme_font_size_override("font_size", 18)
	nl.add_theme_color_override("font_color", Color(1, 1, 1));
	name_row.add_child(nl)
	if m.get("tier", "") == "recommended":
		var badge = Label.new(); badge.text = "★ RECOMMENDED"; badge.add_theme_font_size_override("font_size", 12)
		badge.add_theme_color_override("font_color", Color(0.3, 1, 0.3));
		name_row.add_child(badge)
	if is_active:
		var abadge = Label.new(); abadge.text = "● ACTIVE"; abadge.add_theme_font_size_override("font_size", 12)
		abadge.add_theme_color_override("font_color", Color(0.3, 0.6, 1)); name_row.add_child(abadge)

	var dl = Label.new();
	dl.text = m.get("description", ""); dl.add_theme_font_size_override("font_size", 13)
	dl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6)); dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART;
	info.add_child(dl)

	var stats = Label.new()
	stats.text = "Size: " + m.get("size", "?") + "  |  VRAM: " + m.get("vram", "?") + "  |  Speed: " + m.get("speed", "?") + "  |  Quality: " + m.get("quality", "?")
	stats.add_theme_font_size_override("font_size", 12);
	stats.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5)); info.add_child(stats)

	var btn = Button.new(); btn.custom_minimum_size = Vector2(120, 40);
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var mid = m.get("id", "")
	if is_installed and is_active:
		btn.text = "Active"; btn.disabled = true
	elif is_installed:
		btn.text = "Use This";
		btn.add_theme_color_override("font_color", Color(0.3, 0.8, 1))
		btn.pressed.connect(_on_switch_model.bind(mid, is_setup))
	else:
		btn.text = "Download"; btn.add_theme_color_override("font_color", Color(0.2, 1, 0.2))
		btn.pressed.connect(_on_download_model.bind(mid, is_setup))
	hb.add_child(btn)

	return pc

func _on_download_model(model_id: String, is_setup: bool):
	EventBus.play_sfx.emit("click")
	_pulling_model = model_id
	_model_progress_bar.visible = true;
	_model_progress_bar.value = 0
	_model_progress_label.text = "Starting download: " + model_id + "..."
	await NetworkManager.pull_model(model_id)

func _poll_pull_progress():
	if _pulling_model == "": return
	var p = await NetworkManager.get_pull_progress(_pulling_model)
	if p.has("error"): return
	var status = p.get("status", "")
	var pct = p.get("percent", 0)
	var detail = p.get("detail", "")
	_model_progress_bar.value = pct
	_model_progress_label.text = _pulling_model + ": " + detail + " (" + str(pct) + "%)"
	if status == "done":
		_pulling_model = ""
		_model_progress_label.text = "Download complete! You can now select the model."
		_model_progress_bar.visible = false
		var catalog = await NetworkManager.get_model_catalog()
		if not catalog.has("error"):
			_model_catalog = catalog.get("catalog", [])
			_current_model = catalog.get("current_model", "")
			if model_setup_panel.visible: _show_model_setup(_model_catalog, true)
			if settings_panel.visible: _refresh_settings_models()
	elif status == "error":
		_pulling_model = ""
		_model_progress_label.text = "Download failed: " + p.get("error", "Unknown error")
		_model_progress_bar.visible = false

func _on_switch_model(model_id: String, is_setup: bool):
	EventBus.play_sfx.emit("click")
	var res = await NetworkManager.switch_model(model_id)
	if res.has("error"):
		_model_progress_label.text = "Switch failed: " + str(res.get("error", ""))
		return
		
	if api_status_lbl:
		api_status_lbl.text = "Cloud API Disabled. Using Local."
		api_status_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		
	_current_model = model_id
	if is_setup:
		model_setup_panel.hide();
		menu_panel.show()
	_update_model_hint()
	if settings_panel.visible:
		_refresh_settings_models()

func _build_stat_alloc_panel():
	stat_alloc_panel = Panel.new(); stat_alloc_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	stat_alloc_panel.self_modulate = Color(0.1, 0.1, 0.2, 0.98); stat_alloc_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(stat_alloc_panel);
	stat_alloc_panel.hide()
	var av = VBoxContainer.new(); av.set_anchors_preset(Control.PRESET_FULL_RECT)
	av.alignment = BoxContainer.ALIGNMENT_CENTER; av.add_theme_constant_override("separation", 20)
	av.mouse_filter = Control.MOUSE_FILTER_IGNORE; stat_alloc_panel.add_child(av)
	points_left_label = Label.new();
	points_left_label.text = "Points remaining: " + str(max_manual_points)
	points_left_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	points_left_label.add_theme_color_override("font_color", Color(1, 1, 0))
	points_left_label.add_theme_font_size_override("font_size", 26); av.add_child(points_left_label)
	var sg = GridContainer.new(); sg.columns = 3;
	sg.add_theme_constant_override("h_separation", 15)
	sg.add_theme_constant_override("v_separation", 10); sg.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	sg.mouse_filter = Control.MOUSE_FILTER_IGNORE; av.add_child(sg)
	for k in ["constitution","intelligence","charisma","wealth","luck","social","willpower"]:
		var display = k.capitalize()
		var l = Label.new();
		l.text = display; l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		l.custom_minimum_size = Vector2(100, 40); l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER; l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var sl = HSlider.new();
		sl.custom_minimum_size = Vector2(220, 40); sl.max_value = 100; sl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var vla = Label.new(); vla.text = " 0";
		vla.custom_minimum_size = Vector2(40, 40); vla.vertical_alignment = VERTICAL_ALIGNMENT_CENTER; vla.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sl.value_changed.connect(_on_slider.bind(k, sl, vla)); stat_sliders[k] = sl
		sg.add_child(l); sg.add_child(sl); sg.add_child(vla)
	var ab = VBoxContainer.new();
	ab.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	ab.add_theme_constant_override("separation", 15); ab.mouse_filter = Control.MOUSE_FILTER_IGNORE; av.add_child(ab)
	var cb = Button.new(); cb.text = "Confirm & Start";
	cb.custom_minimum_size = Vector2(280, 55)
	cb.add_theme_color_override("font_color", Color(0.2, 1, 0.2)); cb.pressed.connect(_on_confirm); ab.add_child(cb)
	var bb = Button.new(); bb.text = "Back to Menu";
	bb.custom_minimum_size = Vector2(280, 45)
	bb.pressed.connect(func(): EventBus.play_sfx.emit("click"); stat_alloc_panel.hide(); menu_panel.show()); ab.add_child(bb)

func _on_slider(nv: float, key: String, slider: HSlider, vlbl: Label):
	var used = 0
	for k in stat_sliders.keys():
		if stat_sliders[k] != slider: used += stat_sliders[k].value
	if used + nv > max_manual_points: nv = max_manual_points - used;
	slider.set_value_no_signal(nv)
	vlbl.text = " " + str(nv)
	points_left_label.text = "Points remaining: " + str(max_manual_points - (used + nv))

func _on_start():
	EventBus.play_sfx.emit("click")
	if alloc_option.get_selected_id() == 0:
		var s = {"constitution":10,"intelligence":10,"charisma":10,"wealth":10,"luck":10,"social":10,"willpower":10}
		for i in range(80): s[s.keys()[randi() % s.size()]] += 1
		_dispatch(s)
	else: menu_panel.hide();
	stat_alloc_panel.show()

func _on_confirm():
	EventBus.play_sfx.emit("click")
	var s = {}
	for k in stat_sliders.keys(): s[k] = int(stat_sliders[k].value)
	_dispatch(s)

func _dispatch(stats: Dictionary):
	var wi = world_option.get_selected_id();
	var wk = world_option.get_item_metadata(wi)
	if wk == null: wk = "modern_city"
	var cn = name_input.text if name_input.text != "" else "Traveler"
	var gi = gender_option.get_selected_id()
	var gs = "Random"
	if gi == 1: gs = "Male"
	elif gi == 2: gs = "Female"
	EventBus.game_start_requested.emit(wk, cn, gs, diff_option.get_item_text(diff_option.get_selected_id()), stats)
