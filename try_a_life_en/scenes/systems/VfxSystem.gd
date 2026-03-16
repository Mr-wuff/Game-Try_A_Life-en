extends Control
class_name VFXSystem
var cinematic_bg: ColorRect; var damage_overlay: ColorRect

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	damage_overlay = ColorRect.new(); 
	damage_overlay.color = Color(1,0,0,0)
	damage_overlay.set_anchors_preset(Control.PRESET_FULL_RECT); 
	damage_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(damage_overlay)
	EventBus.health_warning.connect(_warn); 
	EventBus.spawn_floating_text.connect(_float); 
	EventBus.play_sfx.connect(_sfx_flash)

func _warn():
	var tw = create_tween()
	tw.tween_property(damage_overlay,"color:a",0.25,0.15); tw.tween_property(damage_overlay,"color:a",0.08,0.1)
	tw.tween_property(damage_overlay,"color:a",0.2,0.15); tw.tween_property(damage_overlay,"color:a",0.0,0.5)

func _float(msg: String, pos: bool):
	var l = Label.new(); 
	l.text = msg; 
	l.add_theme_font_size_override("font_size", 36)
	l.add_theme_color_override("font_color", Color(0.2,1.0,0.3) if pos else Color(1.0,0.3,0.3))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.position = Vector2(size.x * randf_range(0.2,0.8), size.y * 0.4); 
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l); l.scale = Vector2(0.3,0.3)
	var tw = create_tween(); 
	tw.tween_property(l,"scale",Vector2(1.2,1.2),0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tw.finished; 
	await get_tree().create_timer(0.5).timeout
	var tw2 = create_tween().set_parallel(true)
	tw2.tween_property(l,"position:y",l.position.y-80,1.5); 
	tw2.tween_property(l,"modulate:a",0.0,1.5)
	await tw2.finished; l.queue_free()

func _sfx_flash(n: String):
	if n == "success": _flash(Color(1,0.85,0.2,0.15))
	elif n == "fail": _flash(Color(1,0.1,0.1,0.15))
func _flash(c: Color):
	var r = ColorRect.new(); 
	r.color = c; 
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE; 
	add_child(r)
	var tw = create_tween(); 
	tw.tween_property(r,"color:a",0.0,0.4); 
	await tw.finished; r.queue_free()

func play_epic_ending_cinematic(epic: String, age: int, cause: String):
	mouse_filter = Control.MOUSE_FILTER_STOP
	cinematic_bg = ColorRect.new(); 
	cinematic_bg.color = Color.BLACK
	cinematic_bg.set_anchors_preset(Control.PRESET_FULL_RECT); 
	cinematic_bg.modulate.a = 0.0; add_child(cinematic_bg)
	var f = create_tween(); f.tween_property(cinematic_bg,"modulate:a",1.0,2.0); 
	await f.finished
	var divider = "—— The wheel of fate turns on ——"
	var ct = GameManager.loading_texts
	if ct is Dictionary and ct.has("ending_divider"): divider = ct["ending_divider"]
	var lbl = RichTextLabel.new(); lbl.bbcode_enabled = true
	lbl.text = "[center][color=#ff3333]Lived to age " + str(age) + "[/color]\nCause of death: " + cause + "[/center]\n\n[center][color=#a9a9a9]" + divider + "[/color][/center]\n\n[center]" + epic + "[/center]"
	lbl.add_theme_font_size_override("normal_font_size",22); 
	lbl.add_theme_constant_override("line_separation",8)
	lbl.custom_minimum_size = Vector2(size.x-80,2000); 
	lbl.position = Vector2(40,size.y+100); add_child(lbl)
	var st = create_tween(); 
	st.tween_property(lbl,"position:y",-800.0,max(15.0,epic.length()*0.12)).set_trans(Tween.TRANS_LINEAR)
	await st.finished; 
	await get_tree().create_timer(1.5).timeout
	var cc = CenterContainer.new(); 
	cc.set_anchors_preset(Control.PRESET_FULL_RECT); 
	add_child(cc)
	var btn = Button.new(); 
	btn.text = "Enter the Cycle Anew"; 
	btn.custom_minimum_size = Vector2(280,60)
	btn.add_theme_font_size_override("font_size",24); 
	btn.modulate.a = 0.0
	btn.pressed.connect(func(): get_tree().reload_current_scene()); 
	cc.add_child(btn)
	create_tween().tween_property(btn,"modulate:a",1.0,1.5)
