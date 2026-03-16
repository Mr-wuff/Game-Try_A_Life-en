extends Control

@onready var intro_player: VideoStreamPlayer = $IntroPlayer

# ⚠️ 注意：这里必须填入你的“主菜单场景”的真实路径！
# 例如："res://main.tscn" 或 "res://scenes/ui/MainMenu.tscn"
const MAIN_MENU_SCENE_PATH = "res://scenes/main/main.tscn" 

var _is_transitioning: bool = false
	
func _ready():
	# ==========================================
	# 【核心修复】：暴力强制铺满全屏
	# ==========================================
	# 1. 强制根节点 (IntroScene) 铺满当前窗口
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport_rect().size 
	
	# 2. 强制视频播放器铺满根节点，并开启等比拉伸
	intro_player.set_anchors_preset(Control.PRESET_FULL_RECT)
	intro_player.size = size
	intro_player.expand = true 
	# ==========================================

	# 确保鼠标不会阻挡点击事件
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	intro_player.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# 开始播放视频
	intro_player.play()
	
	# 监听视频播放结束的信号
	intro_player.finished.connect(_on_video_finished)

# 监听玩家输入（点击鼠标或按任意键盘按键跳过视频）
func _input(event):
	if _is_transitioning: return
	
	if event is InputEventMouseButton and event.pressed:
		_fade_out_and_start_game()
	elif event is InputEventKey and event.pressed:
		_fade_out_and_start_game()

func _on_video_finished():
	if _is_transitioning: return
	_fade_out_and_start_game()

func _fade_out_and_start_game():
	_is_transitioning = true
	
	# 1. 声音平滑淡出 (防止声音突然切断)
	var bgm_bus_idx = AudioServer.get_bus_index("Master")
	var old_vol = AudioServer.get_bus_volume_db(bgm_bus_idx)
	var tw_audio = create_tween()
	tw_audio.tween_method(func(v): AudioServer.set_bus_volume_db(bgm_bus_idx, v), old_vol, -80.0, 0.5)
	
	# 2. 画面平滑变黑
	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.z_index = 100
	add_child(fade_rect)
	
	var tw_visual = create_tween()
	tw_visual.tween_property(fade_rect, "color:a", 1.0, 0.5)
	
	# 等待淡出动画结束
	await tw_visual.finished
	
	# 3. 恢复音量并切换到主菜单
	AudioServer.set_bus_volume_db(bgm_bus_idx, old_vol)
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
