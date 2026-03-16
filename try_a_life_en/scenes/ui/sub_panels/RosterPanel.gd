extends Control
var list_container: VBoxContainer; 
var inner_panel: Panel
func _ready(): _build_layout(); hide()
func _build_layout():
	set_anchors_preset(Control.PRESET_FULL_RECT); 
	mouse_filter = Control.MOUSE_FILTER_STOP
	var bg = ColorRect.new(); 
	bg.set_anchors_preset(Control.PRESET_FULL_RECT); 
	bg.color = Color(0,0,0,0.6); 
	add_child(bg)
	var bgb = Button.new(); 
	bgb.set_anchors_preset(Control.PRESET_FULL_RECT); 
	bgb.flat = true; 
	bgb.pressed.connect(close_panel); 
	add_child(bgb)
	inner_panel = Panel.new(); 
	inner_panel.custom_minimum_size = Vector2(400,600); 
	inner_panel.size = Vector2(400,600)
	inner_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER); 
	inner_panel.self_modulate = Color(0.15,0.1,0.1,0.98); 
	add_child(inner_panel)
	var vb = VBoxContainer.new(); 
	vb.set_anchors_preset(Control.PRESET_FULL_RECT)
	vb.set_offset(SIDE_LEFT,20); 
	vb.set_offset(SIDE_TOP,20); 
	vb.set_offset(SIDE_RIGHT,-20); 
	vb.set_offset(SIDE_BOTTOM,-20); 
	inner_panel.add_child(vb)
	var t = Label.new(); 
	t.text = "【Fate Bonds】"; 
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size",24); 
	vb.add_child(t)
	var sc = ScrollContainer.new(); 
	sc.size_flags_vertical = Control.SIZE_EXPAND_FILL; 
	sc.custom_minimum_size = Vector2(0,450); 
	vb.add_child(sc)
	list_container = VBoxContainer.new(); 
	list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_container.add_theme_constant_override("separation",15); 
	sc.add_child(list_container)
	var cb = Button.new(); 
	cb.text = "Close"; 
	cb.custom_minimum_size = Vector2(0,50); 
	cb.pressed.connect(close_panel); 
	vb.add_child(cb)
func open_panel():
	_refresh(); show(); 
	inner_panel.scale = Vector2(0.8,0.8)
	create_tween().tween_property(inner_panel,"scale",Vector2.ONE,0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
func close_panel(): EventBus.play_sfx.emit("click"); hide()
func _refresh():
	for c in list_container.get_children(): c.queue_free()
	var tags = GameManager.causal_tags
	if tags.is_empty():
		var l = Label.new(); l.text = "You walk alone, untouched by fate."; l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; list_container.add_child(l); return
	for tag in tags:
		var l = Label.new(); l.text = "✨ " + str(tag); l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.add_theme_color_override("font_color",Color(1.0,0.6,0.8)); list_container.add_child(l)
