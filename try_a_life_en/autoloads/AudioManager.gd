extends Node

var bgm_player_1: AudioStreamPlayer
var bgm_player_2: AudioStreamPlayer
var active_bgm_player: AudioStreamPlayer
var inactive_bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var type_player: AudioStreamPlayer
var current_bgm_stream: AudioStream

func _ready():
	bgm_player_1 = AudioStreamPlayer.new(); add_child(bgm_player_1)
	bgm_player_2 = AudioStreamPlayer.new(); add_child(bgm_player_2)
	sfx_player = AudioStreamPlayer.new(); add_child(sfx_player)
	type_player = AudioStreamPlayer.new(); add_child(type_player)
	bgm_player_1.bus = "BGM"; bgm_player_2.bus = "BGM"
	sfx_player.bus = "SFX"; type_player.bus = "SFX"
	bgm_player_1.volume_db = -80.0; bgm_player_2.volume_db = -80.0
	active_bgm_player = bgm_player_1; inactive_bgm_player = bgm_player_2
	bgm_player_1.finished.connect(_on_bgm_done.bind(bgm_player_1))
	bgm_player_2.finished.connect(_on_bgm_done.bind(bgm_player_2))
	EventBus.play_bgm.connect(crossfade_bgm)

func _on_bgm_done(p: AudioStreamPlayer):
	if p == active_bgm_player and p.stream: p.play()

func crossfade_bgm(stream: AudioStream, dur: float = 2.0):
	if not stream or current_bgm_stream == stream: return
	current_bgm_stream = stream
	var old = active_bgm_player; active_bgm_player = inactive_bgm_player; inactive_bgm_player = old
	active_bgm_player.stream = stream; active_bgm_player.volume_db = -80.0; active_bgm_player.play()
	var tw = create_tween().set_parallel(true)
	tw.tween_property(active_bgm_player, "volume_db", -5.0, dur).set_trans(Tween.TRANS_SINE)
	if inactive_bgm_player.playing:
		tw.tween_property(inactive_bgm_player, "volume_db", -80.0, dur).set_trans(Tween.TRANS_SINE)
		tw.chain().tween_callback(inactive_bgm_player.stop)

func play_sfx(stream: AudioStream, pr: float = 0.0):
	if stream:
		sfx_player.stream = stream
		sfx_player.pitch_scale = randf_range(1.0 - pr, 1.0 + pr) if pr > 0 else 1.0
		sfx_player.play()

func play_type_sound(stream: AudioStream):
	if stream: type_player.stream = stream; type_player.pitch_scale = randf_range(0.9, 1.1); type_player.play()
