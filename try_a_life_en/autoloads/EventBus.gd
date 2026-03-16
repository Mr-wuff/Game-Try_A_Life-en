extends Node

signal game_start_requested(world_key: String, char_name: String, gender: String, diff: String, stats: Dictionary)
signal game_state_updated(state_dict: Dictionary)
signal game_over(epic_ending: String, age: int, cause: String)

signal event_generated(event_data: Dictionary)
signal choice_made(index: int)
signal node_investment_made(investments: Dictionary)

signal ui_show_loading(text: String)
signal ui_hide_loading()
signal screen_shake_requested(intensity: float, duration: float)
signal spawn_floating_text(msg: String, is_positive: bool)

signal stat_changed(stat_name: String, change_val: int)
signal health_warning()

signal play_sfx(sfx_name: String)
signal play_bgm(bgm_stream: AudioStream)
signal bgm_stage_changed(age: int)
