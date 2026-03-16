extends Panel

var list_vbox: VBoxContainer
var detail_panel: Panel
var detail_text: RichTextLabel
var _data_cache: Array = []

func _ready():
	set_anchors_preset(Control.PRESET_FULL_RECT)
	self_modulate = Color(0.05, 0.05, 0.08, 0.98)
	hide()
	
	var mv = VBoxContainer.new()
	mv.set_anchors_preset(Control.PRESET_FULL_RECT)
	mv.set_offset(SIDE_LEFT, 30); mv.set_offset(SIDE_TOP, 30); mv.set_offset(SIDE_RIGHT, -30); mv.set_offset(SIDE_BOTTOM, -30)
	mv.add_theme_constant_override("separation", 20)
	add_child(mv)
	
	var title = Label.new()
	title.text = "🏆 Hall of Fame & Legends"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	mv.add_child(title)
	
	var hbox = HBoxContainer.new()
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 20)
	mv.add_child(hbox)
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_stretch_ratio = 1.0
	hbox.add_child(scroll)
	list_vbox = VBoxContainer.new()
	list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_vbox.add_theme_constant_override("separation", 10)
	scroll.add_child(list_vbox)
	
	detail_panel = Panel.new()
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_panel.size_flags_stretch_ratio = 1.8
	var dstyle = StyleBoxFlat.new(); dstyle.bg_color = Color(0.15, 0.15, 0.2, 0.8); dstyle.set_content_margin_all(20)
	detail_panel.add_theme_stylebox_override("panel", dstyle)
	hbox.add_child(detail_panel)
	
	var dscroll = ScrollContainer.new()
	dscroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	detail_panel.add_child(dscroll)
	
	detail_text = RichTextLabel.new()
	detail_text.bbcode_enabled = true
	detail_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_text.fit_content = true
	detail_text.add_theme_font_size_override("normal_font_size", 16)
	detail_text.text = "[center][color=#666666]Click a legend on the left to read their life story...[/color][/center]"
	dscroll.add_child(detail_text)
	
	var close_btn = Button.new()
	close_btn.text = "Back to Menu"
	close_btn.custom_minimum_size = Vector2(200, 50)
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_btn.pressed.connect(func(): EventBus.play_sfx.emit("click"); hide())
	mv.add_child(close_btn)

func open_panel():
	show()
	_refresh_board()

func _refresh_board():
	for c in list_vbox.get_children(): c.queue_free()
	var l = Label.new(); l.text = "Connecting to Akashic Records..."; l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	list_vbox.add_child(l)
	
	var data = await NetworkManager.get_leaderboard()
	
	# 【核心防御】在 await 恢复后，第一时间检查标签 l 或当前面板是否还存活
	if not is_instance_valid(l) or not is_inside_tree():
		return # 如果玩家已经关闭了面板，直接丢弃数据，终止函数
		
	if typeof(data) != TYPE_ARRAY:
		l.text = "Failed to load legends."
		return
		
	_data_cache = data
	l.queue_free()
	
	if data.size() == 0:
		var empty_lbl = Label.new(); empty_lbl.text = "No legends recorded yet."; empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		list_vbox.add_child(empty_lbl)
		return
	
	for i in range(data.size()):
		var entry = data[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 65)
		var rank_str = "#" + str(i+1) + "  " + entry.get("name", "Unknown") + "\n[color=#888888]Score: " + str(entry.get("score", 0)) + "[/color]"
		btn.text = "#" + str(i+1) + " " + entry.get("name", "Unknown") + " | Pts: " + str(entry.get("score", 0))
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_legend_clicked.bind(i))
		
		if i == 0: btn.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0)) 
		elif i == 1: btn.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9)) 
		elif i == 2: btn.add_theme_color_override("font_color", Color(0.8, 0.5, 0.2)) 
		
		list_vbox.add_child(btn)

func _on_legend_clicked(idx: int):
	EventBus.play_sfx.emit("click")
	if idx < 0 or idx >= _data_cache.size(): return
	
	var entry = _data_cache[idx]
	var text = "[center][b][color=#ffd700]" + entry.get("name", "Unknown") + "[/color][/b][/center]\n"
	text += "[center][color=#aaaaaa]World: " + entry.get("world", "Unknown") + " | Lived " + str(entry.get("age", 0)) + " years[/color][/center]\n"
	text += "[center][color=#aaaaaa]Cause of Death: " + entry.get("cause", "Unknown") + "[/color][/center]\n\n"
	
	text += "[color=#00ffff]━━━ Epic Biography ━━━[/color]\n"
	text += entry.get("biography", "No biography recorded.") + "\n\n"
	
	var hist = entry.get("history", [])
	if hist.size() > 0:
		text += "[color=#ff8888]━━━ Life Trajectory (Final Echoes) ━━━[/color]\n"
		for h in hist:
			text += "[color=#cccccc]" + str(h) + "[/color]\n"
			
	detail_text.text = text
