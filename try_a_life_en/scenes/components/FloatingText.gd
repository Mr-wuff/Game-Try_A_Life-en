extends Label
class_name FloatingText

func setup(msg: String, is_positive: bool, start_position: Vector2):
	text = msg
	position = start_position
	add_theme_font_size_override("font_size", 36)
	add_theme_constant_override("outline_size", 5)
	add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	if is_positive:
		add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	else:
		add_theme_color_override("font_color", Color(1.0, 0.25, 0.2))
	modulate.a = 0.0; scale = Vector2(0.3, 0.3)
	pivot_offset = size / 2.0
	_play_animation(is_positive)

func _play_animation(is_positive: bool):
	var overshoot = 1.3 if not is_positive else 1.2
	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, 0.15)
	tw.tween_property(self, "scale", Vector2(overshoot, overshoot), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tw.finished
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_SINE)
	await get_tree().create_timer(0.5).timeout
	var tw2 = create_tween().set_parallel(true)
	tw2.tween_property(self, "position:y", position.y - 120.0, 1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tw2.tween_property(self, "modulate:a", 0.0, 1.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tw2.tween_property(self, "scale", Vector2(0.7, 0.7), 1.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tw2.chain().tween_callback(queue_free)
