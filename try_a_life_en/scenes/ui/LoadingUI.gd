extends Control

# --- UI 与 背景节点 ---
var bg_base: ColorRect
var bg_spring: TextureRect
var bg_summer: TextureRect
var bg_autumn: TextureRect
var bg_winter: TextureRect

var vignette_rect: ColorRect
var title_label: RichTextLabel 
var flavor_label: Label
var center_vbox: VBoxContainer

# --- 粒子系统 ---
var p_spring: CPUParticles2D
var p_summer: CPUParticles2D
var p_autumn: CPUParticles2D
var p_winter: CPUParticles2D

# --- 动画逻辑 ---
var dots_timer: float = 0.0
var dots_count: int = 0
var base_text: String = "Fate unfolds"
var flavor_swap_timer: float = 0.0
var flavor_swap_interval: float = 3.0
var transition_tween: Tween
var current_season: int = -99 # 初始设为一个绝对不匹配的值

# --- 文本库 ---
var flavor_universal = ["The threads of destiny intertwine...","The wheels of fate turn slowly...","Time flows ever onward...","Nothing is certain yet..."]
var flavor_modern = ["Neon lights flicker in the distance...","Your phone buzzes once...","Traffic hums outside the window...","Another page torn from the calendar...","The coffee has gone cold...","A convenience store bell chimes nearby..."]
var flavor_xianxia = ["Spiritual energy surges like a tide...","The heavens conceal their secrets...","All things follow the Dao...","A crane glides above the clouds...","Flames dance within the alchemy furnace...","Ancient runes shimmer on the jade slip..."]
var flavor_medieval = ["Candlelight wavers behind palace walls...","War drums echo from afar...","Bamboo scrolls rustle in the study...","Undercurrents stir in the royal court...","A sealed letter slips under the door...","The night watchman's clapper draws near..."]

var titles_universal = ["Time passes, fate continues","The seasons turn","Another year begins"]
var titles_modern = ["The days go by","Just another ordinary day?","Life goes on","The city never stops for anyone"]
var titles_xianxia = ["Time flows, the Dao endures","Years pass, cultivation continues","Karma cycles, cause meets effect"]
var titles_medieval = ["Seasons change, years slip away","Dynasties rise and fall","The winds of change are blowing"]

const VIGNETTE_SHADER = """
shader_type canvas_item;
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float intensity = 1.5;
void fragment() {
	vec2 uv = UV - 0.5;
	float dist = length(uv) * 2.0;
	dist = pow(dist, intensity);
	COLOR = vec4(vignette_color.rgb, dist * vignette_color.a);
}
"""

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_preset(Control.PRESET_FULL_RECT)
	z_index = 100
	_build_ui()
	hide(); modulate.a = 0.0
	EventBus.ui_show_loading.connect(show_loading)
	EventBus.ui_hide_loading.connect(hide_loading)

func _process(delta):
	if not visible: return
	dots_timer += delta
	if dots_timer > 0.4: 
		dots_timer = 0.0
		dots_count = (dots_count+1)%4
		# [修改] 去掉了 [wave] 特效，文字不再抖动，显得更加沉稳
		title_label.text = "[center][color=#ffffff]" + base_text + ".".repeat(dots_count) + "[/color][/center]"
		
	flavor_swap_timer += delta
	if flavor_swap_timer >= flavor_swap_interval: 
		flavor_swap_timer = 0.0; _swap()
		
	# 保留轻微的呼吸感（透明度变化），但去除了文字物理上的扭动
	title_label.modulate.a = 0.85 + sin(Time.get_ticks_msec() * 0.002) * 0.15

func _build_ui():
	# 1. 极暗底色打底
	bg_base = ColorRect.new(); bg_base.color = Color(0.02, 0.02, 0.04, 1.0)
	bg_base.set_anchors_preset(Control.PRESET_FULL_RECT); bg_base.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg_base)
	
	# 2. 四季背景纹理层 (动态加载美术资产)
	var bg_layer = Control.new()
	bg_layer.set_anchors_preset(Control.PRESET_FULL_RECT); bg_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg_layer)
	
	bg_spring = _create_bg_rect("res://assets/vfx/bg_spring.png", Color(0.1, 0.2, 0.1, 1.0))
	bg_summer = _create_bg_rect("res://assets/vfx/bg_summer.png", Color(0.1, 0.3, 0.4, 1.0))
	bg_autumn = _create_bg_rect("res://assets/vfx/bg_autumn.png", Color(0.3, 0.15, 0.05, 1.0))
	bg_winter = _create_bg_rect("res://assets/vfx/bg_winter.png", Color(0.8, 0.85, 0.9, 1.0))
	
	bg_layer.add_child(bg_spring); bg_layer.add_child(bg_summer); bg_layer.add_child(bg_autumn); bg_layer.add_child(bg_winter)
	
	# 3. 四季意象粒子层 (载入特效图片)
	var pt_layer = Control.new()
	pt_layer.set_anchors_preset(Control.PRESET_FULL_RECT); pt_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(pt_layer)
	
	# [修改] 大幅减少粒子数量 (amount 参数)，从原来的 50~100 降到了 15~30，作为点缀而非满屏乱飞
	p_spring = _create_particles("res://assets/vfx/pt_spring.png", 15, Vector2(0, -1), Vector2(0, -15), 60.0, 30.0, true)
	p_spring.position = Vector2(640, 750) 
	
	p_summer = _create_particles("res://assets/vfx/pt_summer.png", 20, Vector2(0, -1), Vector2(0, -5), 180.0, 10.0, false)
	p_summer.position = Vector2(640, 600)
	
	p_autumn = _create_particles("res://assets/vfx/pt_autumn.png", 15, Vector2(1, 1), Vector2(30, 40), 45.0, 80.0, true)
	p_autumn.position = Vector2(0, -100) 
	
	p_winter = _create_particles("res://assets/vfx/pt_winter.png", 30, Vector2(0, 1), Vector2(10, 30), 20.0, 40.0, true)
	p_winter.position = Vector2(640, -50) 
	
	pt_layer.add_child(p_spring); pt_layer.add_child(p_summer); pt_layer.add_child(p_autumn); pt_layer.add_child(p_winter)
	
	# 4. 暗角融合层
	vignette_rect = ColorRect.new()
	vignette_rect.set_anchors_preset(Control.PRESET_FULL_RECT); vignette_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat = ShaderMaterial.new(); var shader = Shader.new()
	shader.code = VIGNETTE_SHADER; mat.shader = shader
	mat.set_shader_parameter("vignette_color", Color(0,0,0,0.85))
	vignette_rect.material = mat
	add_child(vignette_rect)
	
	# 5. 中央文字排版
	var c = CenterContainer.new(); c.set_anchors_preset(Control.PRESET_FULL_RECT); c.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(c)
	center_vbox = VBoxContainer.new(); center_vbox.alignment = BoxContainer.ALIGNMENT_CENTER; center_vbox.add_theme_constant_override("separation", 15); center_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE; c.add_child(center_vbox)
	
	title_label = RichTextLabel.new(); title_label.bbcode_enabled = true; title_label.fit_content = true; title_label.custom_minimum_size = Vector2(800, 0)
	title_label.add_theme_font_size_override("normal_font_size", 36); center_vbox.add_child(title_label)
	flavor_label = Label.new(); flavor_label.add_theme_font_size_override("font_size", 20); flavor_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8)); flavor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; center_vbox.add_child(flavor_label)

func _create_bg_rect(img_path: String, fallback_color: Color) -> TextureRect:
	var tr = TextureRect.new()
	tr.set_anchors_preset(Control.PRESET_FULL_RECT)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE 
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED # 修复好的 Godot 4 API
	tr.modulate.a = 0.0 
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var tex = load(img_path)
	if tex: tr.texture = tex
	else:
		var temp_img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
		temp_img.fill(fallback_color)
		tr.texture = ImageTexture.create_from_image(temp_img)
	return tr

func _create_particles(img_path: String, amount: int, dir: Vector2, grav: Vector2, spread: float, vel: float, enable_rotation: bool) -> CPUParticles2D:
	var p = CPUParticles2D.new()
	p.emitting = false; p.amount = amount; p.lifetime = 5.0
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(800, 100)
	p.direction = dir; p.gravity = grav; p.spread = spread
	p.initial_velocity_min = vel * 0.5; p.initial_velocity_max = vel * 1.5
	
	if enable_rotation:
		p.angle_min = 0; p.angle_max = 360
		p.angular_velocity_min = -90; p.angular_velocity_max = 90
		
	var tex = load(img_path)
	if tex: 
		p.texture = tex; p.scale_amount_min = 0.2; p.scale_amount_max = 0.6
	else:
		p.scale_amount_min = 4.0; p.scale_amount_max = 10.0
		
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0)); curve.add_point(Vector2(0.2, 1)); curve.add_point(Vector2(0.8, 1)); curve.add_point(Vector2(1, 0))
	p.scale_amount_curve = curve
	return p

func _get_flavor() -> Array:
	var ct = GameManager.loading_texts
	if ct is Dictionary and ct.has("flavor_texts"):
		var a = ct["flavor_texts"]; if a is Array and a.size() > 0: return a
	match GameManager.world_key:
		"modern_city": return flavor_modern; 
		"xianxia": return flavor_xianxia; 
		"medieval_war": return flavor_medieval; 
		_: return flavor_universal

func _get_title() -> String:
	var ct = GameManager.loading_texts
	if ct is Dictionary and ct.has("transition_titles"):
		var a = ct["transition_titles"]; if a is Array and a.size() > 0: return a[randi() % a.size()]
	var p: Array
	match GameManager.world_key:
		"modern_city": p = titles_modern; 
		"xianxia": p = titles_xianxia; 
		"medieval_war": p = titles_medieval; 
		_: p = titles_universal
	return p[randi() % p.size()]

func _swap():
	var tw = create_tween(); tw.tween_property(flavor_label, "modulate:a", 0.0, 0.3); await tw.finished
	var pool = _get_flavor(); flavor_label.text = pool[randi() % pool.size()]
	create_tween().tween_property(flavor_label, "modulate:a", 1.0, 0.3)

func show_loading(text: String = ""):
	show()
	var age = 1; if "current_age" in GameManager: age = GameManager.current_age
	
	# [修改] 如果是刚开局 (Age 1)，切入 -1 状态，屏蔽一切四季特效
	if age <= 1:
		_switch_season(-1)
	else:
		_switch_season(age % 4)
	
	base_text = _get_title() if (text == "" or text == "Fate unfolds" or text == "Time flows, destiny continues...") else text
	
	# [修改] 移除开局时的 wave 特效
	title_label.text = "[center][color=#ffffff]" + base_text + "[/color][/center]"
	
	var pool = _get_flavor(); flavor_label.text = pool[randi() % pool.size()]; flavor_label.modulate.a = 1.0
	flavor_swap_timer = 0.0; dots_count = 0
	
	create_tween().tween_property(self, "modulate:a", 1.0, 0.3)

func hide_loading():
	var tw = create_tween(); tw.tween_property(self, "modulate:a", 0.0, 0.4); await tw.finished
	p_spring.emitting = false; p_summer.emitting = false; p_autumn.emitting = false; p_winter.emitting = false
	hide()

func _switch_season(season_idx: int):
	if current_season == season_idx: return
	current_season = season_idx
	
	if transition_tween and transition_tween.is_valid(): transition_tween.kill()
	transition_tween = create_tween().set_parallel(true)
	var t = 1.2 
	
	# 背景图切换 (如果是 -1，所有的背景透明度全设为 0)
	transition_tween.tween_property(bg_spring, "modulate:a", 0.6 if season_idx == 0 else 0.0, t)
	transition_tween.tween_property(bg_summer, "modulate:a", 0.6 if season_idx == 1 else 0.0, t)
	transition_tween.tween_property(bg_autumn, "modulate:a", 0.6 if season_idx == 2 else 0.0, t)
	transition_tween.tween_property(bg_winter, "modulate:a", 0.6 if season_idx == 3 else 0.0, t)
	
	# 颜色氛围：如果是 -1，使用纯黑底色；否则使用各季节对应的边缘颜色
	var target_vig_color = Color(0, 0, 0, 0.9)
	match season_idx:
		0: target_vig_color = Color(0.05, 0.15, 0.05, 0.85) 
		1: target_vig_color = Color(0.05, 0.1, 0.2, 0.85)   
		2: target_vig_color = Color(0.2, 0.05, 0.0, 0.85)   
		3: target_vig_color = Color(0.1, 0.15, 0.25, 0.85)  
		-1: target_vig_color = Color(0, 0, 0, 0.9) # 初见开局：绝对纯净的暗黑
		
	var mat = vignette_rect.material as ShaderMaterial
	var start_color = mat.get_shader_parameter("vignette_color")
	transition_tween.tween_method(func(c: Color): mat.set_shader_parameter("vignette_color", c), start_color, target_vig_color, t)
	
	# 切换粒子 (如果是 -1，四个都会变成 false 从而停发粒子)
	p_spring.emitting = (season_idx == 0)
	p_summer.emitting = (season_idx == 1)
	p_autumn.emitting = (season_idx == 2)
	p_winter.emitting = (season_idx == 3)
