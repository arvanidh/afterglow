extends Node2D
## MENU state - title, pulsing CTA, cosmetic sparks, GEM SHOP overlay.

@onready var title: Label = $UI/CenterBox/VBox/Title
@onready var hint: Label = $UI/CenterBox/VBox/Hint
@onready var best_label: Label = $UI/FPS
@onready var version_label: Label = $UI/Version

var _shop_root: CanvasLayer = null


func _ready() -> void:
	GameState.change_state(GameState.State.MENU)
	version_label.text = "v0.0.7"
	var save := SaveSystem.load_save()
	var runs := int(save.get("runs", 0))
	if runs > 0:
		var best := int(save.get("best_time", 0.0))
		var best_lv := int(save.get("best_level", 1))
		best_label.text = "best %d:%02d  |  LV %d  |  %d runs" % [best / 60, best % 60, best_lv, runs]
	else:
		best_label.text = ""
	var gem_label := Label.new()
	gem_label.name = "GemLabel"
	var gems: int = int(save.get("gems", 0))
	gem_label.text = "%d gems" % gems
	gem_label.add_theme_font_size_override("font_size", 20)
	gem_label.add_theme_color_override("font_color", Color(1.0, 0.72, 0.0))
	gem_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$UI/CenterBox/VBox.add_child(gem_label)
	# Character selector
	var char_id := SaveSystem.get_selected_character()
	var char_data := CharacterDb.get_by_id(char_id)
	var char_label := Label.new()
	char_label.name = "CharLabel"
	char_label.text = "Playing as: %s" % String(char_data["name"])
	char_label.add_theme_font_size_override("font_size", 16)
	char_label.add_theme_color_override("font_color", char_data["color"])
	char_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$UI/CenterBox/VBox.add_child(char_label)
	var char_btn := Button.new()
	char_btn.text = "CHANGE CHARACTER"
	char_btn.custom_minimum_size = Vector2(200, 45)
	char_btn.add_theme_font_size_override("font_size", 18)
	char_btn.pressed.connect(_open_character_select)
	$UI/CenterBox/VBox.add_child(char_btn)
	_pulse(title, 1.2)
	_pulse(hint, 0.75)
	var controls := Label.new()
	controls.text = "left thumb to move  |  tap diamond to dash"
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_theme_font_size_override("font_size", 14)
	controls.add_theme_color_override("font_color", Color(1, 1, 1, 0.35))
	$UI/CenterBox/VBox.add_child(controls)
	var level_map_btn := Button.new()
	level_map_btn.text = "LEVEL MAP"
	level_map_btn.custom_minimum_size = Vector2(200, 50)
	level_map_btn.add_theme_font_size_override("font_size", 22)
	level_map_btn.pressed.connect(_open_level_map)
	$UI/CenterBox/VBox.add_child(level_map_btn)
	# Daily Challenge button
	var daily_btn := Button.new()
	daily_btn.text = "DAILY CHALLENGE"
	daily_btn.custom_minimum_size = Vector2(200, 50)
	daily_btn.add_theme_font_size_override("font_size", 22)
	if DailyChallenge.is_daily_completed():
		daily_btn.text = "DAILY ✓ COMPLETED"
		daily_btn.disabled = true
	daily_btn.pressed.connect(_start_daily)
	$UI/CenterBox/VBox.add_child(daily_btn)
	# Show daily best if completed
	if DailyChallenge.is_daily_completed():
		var daily_best := DailyChallenge.get_daily_best()
		var daily_label := Label.new()
		daily_label.text = "Today: LV %d · %d kills" % [int(daily_best.get("level", 0)), int(daily_best.get("kills", 0))]
		daily_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		daily_label.add_theme_font_size_override("font_size", 14)
		daily_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.4))
		$UI/CenterBox/VBox.add_child(daily_label)
	var shop_btn := Button.new()
	shop_btn.text = "SHOP"
	shop_btn.custom_minimum_size = Vector2(200, 50)
	shop_btn.add_theme_font_size_override("font_size", 22)
	shop_btn.pressed.connect(_open_shop)
	$UI/CenterBox/VBox.add_child(shop_btn)
	var help_btn := Button.new()
	help_btn.text = "HOW TO PLAY"
	help_btn.custom_minimum_size = Vector2(200, 50)
	help_btn.add_theme_font_size_override("font_size", 22)
	help_btn.pressed.connect(_open_tutorial)
	$UI/CenterBox/VBox.add_child(help_btn)
	# Missions button
	var missions_btn := Button.new()
	missions_btn.text = "MISSIONS"
	missions_btn.custom_minimum_size = Vector2(200, 50)
	missions_btn.add_theme_font_size_override("font_size", 22)
	missions_btn.pressed.connect(_open_missions)
	$UI/CenterBox/VBox.add_child(missions_btn)
	# Settings button
	var settings_btn := Button.new()
	settings_btn.text = "SETTINGS"
	settings_btn.custom_minimum_size = Vector2(200, 50)
	settings_btn.add_theme_font_size_override("font_size", 22)
	settings_btn.pressed.connect(_open_settings)
	$UI/CenterBox/VBox.add_child(settings_btn)


func _pulse(item: CanvasItem, period: float) -> void:
	var tw := create_tween().set_loops()
	tw.tween_property(item, "modulate:a", 0.4, period).set_trans(Tween.TRANS_SINE)
	tw.tween_property(item, "modulate:a", 1.0, period).set_trans(Tween.TRANS_SINE)


func _unhandled_input(event: InputEvent) -> void:
	if _shop_root != null:
		return
	if event is InputEventScreenTouch and event.pressed:
		_spawn_spark(event.position)
		_start_run()


func _start_run() -> void:
	RunState.reset_run()
	GameState.change_state(GameState.State.RUN)
	get_tree().change_scene_to_file("res://scenes/arena.tscn")


func _start_daily() -> void:
	RunState.reset_run()
	RunState.is_daily = true
	GameState.change_state(GameState.State.RUN)
	get_tree().change_scene_to_file("res://scenes/arena.tscn")


func _open_character_select() -> void:
	if _shop_root != null:
		return
	var current := SaveSystem.get_selected_character()
	_shop_root = CanvasLayer.new()
	_shop_root.layer = 20
	add_child(_shop_root)
	var dim := ColorRect.new()
	dim.color = Color(0.01, 0.01, 0.03, 0.92)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shop_root.add_child(dim)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 30
	scroll.offset_right = -30
	scroll.offset_top = 40
	scroll.offset_bottom = -40
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shop_root.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 16)
	scroll.add_child(content)
	var t := Label.new()
	t.text = "CHOOSE YOUR SPARK"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 30)
	t.add_theme_color_override("font_color", Color(0.0, 0.94, 1.0))
	t.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	t.add_theme_constant_override("shadow_offset_y", 2)
	content.add_child(t)
	for char_data: Dictionary in CharacterDb.get_all():
		var id: String = char_data["id"]
		var selected := id == current
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(0, 100)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.08, 0.09, 0.18, 0.95)
		sb.border_color = char_data["color"] if selected else Color(1, 1, 1, 0.15)
		sb.set_border_width_all(2 if selected else 1)
		sb.set_corner_radius_all(10)
		sb.content_margin_left = 16
		sb.content_margin_right = 16
		sb.content_margin_top = 12
		sb.content_margin_bottom = 12
		card.add_theme_stylebox_override("panel", sb)
		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 12)
		card.add_child(hbox)
		var vbox := VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_theme_constant_override("separation", 4)
		hbox.add_child(vbox)
		var name_label := Label.new()
		name_label.text = String(char_data["name"])
		name_label.add_theme_font_size_override("font_size", 22)
		name_label.add_theme_color_override("font_color", char_data["color"])
		vbox.add_child(name_label)
		var desc_label := Label.new()
		desc_label.text = String(char_data["desc"])
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.add_theme_font_size_override("font_size", 14)
		desc_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
		vbox.add_child(desc_label)
		var stats_label := Label.new()
		stats_label.text = "HP %d  |  SPD %d%%  |  DMG %d%%  |  Rate %d%%" % [
			int(char_data["hp"]),
			int(float(char_data["speed_mult"]) * 100),
			int(float(char_data["damage_mult"]) * 100),
			int(float(char_data["rate_mult"]) * 100),
		]
		stats_label.add_theme_font_size_override("font_size", 13)
		stats_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.4))
		vbox.add_child(stats_label)
		if selected:
			var sel_label := Label.new()
			sel_label.text = "SELECTED"
			sel_label.add_theme_font_size_override("font_size", 14)
			sel_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
			sel_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			hbox.add_child(sel_label)
		else:
			var btn := Button.new()
			btn.text = "SELECT"
			btn.custom_minimum_size = Vector2(90, 44)
			btn.add_theme_font_size_override("font_size", 16)
			btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			btn.pressed.connect(_select_character.bind(id))
			hbox.add_child(btn)
		content.add_child(card)
	var close := Button.new()
	close.text = "BACK"
	close.custom_minimum_size = Vector2(0, 55)
	close.add_theme_font_size_override("font_size", 22)
	close.pressed.connect(_close_overlay)
	content.add_child(close)


func _select_character(id: String) -> void:
	SaveSystem.set_selected_character(id)
	Audio.play("powerup", -2.0)
	_close_overlay()
	# Refresh the character label on menu
	var char_data := CharacterDb.get_by_id(id)
	var char_label := get_node_or_null("UI/CenterBox/VBox/CharLabel")
	if char_label:
		char_label.text = "Playing as: %s" % String(char_data["name"])
		char_label.add_theme_color_override("font_color", char_data["color"])


func _open_settings() -> void:
	if _shop_root != null:
		return
	_shop_root = CanvasLayer.new()
	_shop_root.layer = 20
	add_child(_shop_root)
	var dim := ColorRect.new()
	dim.color = Color(0.01, 0.01, 0.03, 0.92)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shop_root.add_child(dim)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 30
	scroll.offset_right = -30
	scroll.offset_top = 40
	scroll.offset_bottom = -40
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shop_root.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 16)
	scroll.add_child(content)
	# Title
	var t := Label.new()
	t.text = "SETTINGS"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 30)
	t.add_theme_color_override("font_color", Color(0.0, 0.94, 1.0))
	t.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	t.add_theme_constant_override("shadow_offset_y", 2)
	content.add_child(t)
	# Music Volume
	content.add_child(_make_slider("Music Volume", Settings.music_volume, func(v): Settings.set_music_volume(v)))
	# SFX Volume
	content.add_child(_make_slider("SFX Volume", Settings.sfx_volume, func(v): Settings.set_sfx_volume(v)))
	# Quality
	var quality_names := ["Low", "Medium", "High"]
	content.add_child(_make_option("Quality", quality_names, Settings.quality, func(i): Settings.set_quality(i)))
	# Toggle: Damage Numbers
	content.add_child(_make_toggle("Show Damage Numbers", Settings.show_damage_numbers, func(): Settings.toggle_damage_numbers()))
	# Toggle: Screen Shake
	content.add_child(_make_toggle("Screen Shake", Settings.screen_shake, func(): Settings.toggle_screen_shake()))
	# Toggle: Auto Level-Up
	content.add_child(_make_toggle("Auto Level-Up", Settings.auto_level_up, func(): Settings.toggle_auto_level_up()))
	# Back button
	var close := Button.new()
	close.text = "BACK"
	close.custom_minimum_size = Vector2(0, 55)
	close.add_theme_font_size_override("font_size", 22)
	close.pressed.connect(_close_overlay)
	content.add_child(close)


func _make_slider(label_text: String, current: float, callback: Callable) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 70)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.09, 0.18, 0.95)
	sb.border_color = Color(1, 1, 1, 0.15)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", sb)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	panel.add_child(vbox)
	var lbl := Label.new()
	lbl.text = "%s: %d%%" % [label_text, int(current * 100)]
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(lbl)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = current
	slider.custom_minimum_size = Vector2(0, 30)
	slider.value_changed.connect(func(v): lbl.text = "%s: %d%%" % [label_text, int(v * 100)]; callback.call(v))
	vbox.add_child(slider)
	return panel


func _make_option(label_text: String, options: Array, current: int, callback: Callable) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 60)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.09, 0.18, 0.95)
	sb.border_color = Color(1, 1, 1, 0.15)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", sb)
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	panel.add_child(hbox)
	var lbl := Label.new()
	lbl.text = label_text
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(lbl)
	for i in range(options.size()):
		var btn := Button.new()
		btn.text = String(options[i])
		btn.custom_minimum_size = Vector2(80, 36)
		btn.add_theme_font_size_override("font_size", 14)
		btn.button_group = ButtonGroup.new() if i == 0 else hbox.get_child(hbox.get_child_count() - 1).button_group if hbox.get_child_count() > 0 else null
		if i == 0:
			var bg := ButtonGroup.new()
			for child in hbox.get_children():
				if child is Button:
					child.button_group = bg
		if i == current:
			btn.button_pressed = true
		var idx := i
		btn.pressed.connect(func(): callback.call(idx))
		hbox.add_child(btn)
	return panel


func _make_toggle(label_text: String, current: bool, callback: Callable) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 60)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.09, 0.18, 0.95)
	sb.border_color = Color(1, 1, 1, 0.15)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", sb)
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)
	var lbl := Label.new()
	lbl.text = label_text
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(lbl)
	var btn := Button.new()
	btn.text = "ON" if current else "OFF"
	btn.custom_minimum_size = Vector2(70, 40)
	btn.add_theme_font_size_override("font_size", 16)
	var status_label := lbl
	btn.pressed.connect(func():
		callback.call()
		btn.text = "ON" if ("ON" != btn.text) else "OFF"
	)
	hbox.add_child(btn)
	return panel


func _open_missions() -> void:
	if _shop_root != null:
		return
	_shop_root = CanvasLayer.new()
	_shop_root.layer = 20
	add_child(_shop_root)
	var dim := ColorRect.new()
	dim.color = Color(0.01, 0.01, 0.03, 0.92)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shop_root.add_child(dim)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 20
	scroll.offset_right = -20
	scroll.offset_top = 40
	scroll.offset_bottom = -40
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shop_root.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	scroll.add_child(content)
	var t := Label.new()
	t.text = "MISSIONS"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 30)
	t.add_theme_color_override("font_color", Color(0.0, 0.94, 1.0))
	t.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	t.add_theme_constant_override("shadow_offset_y", 2)
	content.add_child(t)
	var missions := Missions.get_progress()
	for m: Dictionary in missions:
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(0, 70)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.08, 0.09, 0.18, 0.95)
		if m["completed"] and not m["claimed"]:
			sb.border_color = Color(1.0, 0.72, 0.0)
			sb.set_border_width_all(2)
		elif m["claimed"]:
			sb.border_color = Color(0.3, 1.0, 0.5)
			sb.set_border_width_all(1)
		else:
			sb.border_color = Color(1, 1, 1, 0.1)
			sb.set_border_width_all(1)
		sb.set_corner_radius_all(10)
		sb.content_margin_left = 12
		sb.content_margin_right = 12
		sb.content_margin_top = 8
		sb.content_margin_bottom = 8
		card.add_theme_stylebox_override("panel", sb)
		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 8)
		card.add_child(hbox)
		var vbox := VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.add_theme_constant_override("separation", 2)
		hbox.add_child(vbox)
		var title_label := Label.new()
		title_label.text = String(m["title"])
		title_label.add_theme_font_size_override("font_size", 16)
		title_label.add_theme_color_override("font_color", Color(1.0, 0.72, 0.0) if m["completed"] and not m["claimed"] else Color.WHITE)
		vbox.add_child(title_label)
		var desc_label := Label.new()
		desc_label.text = String(m["desc"])
		desc_label.add_theme_font_size_override("font_size", 13)
		desc_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
		vbox.add_child(desc_label)
		var prog_label := Label.new()
		prog_label.text = "%d / %d" % [int(m["progress"]), int(m["target"])]
		prog_label.add_theme_font_size_override("font_size", 12)
		prog_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5) if m["completed"] else Color(1, 1, 1, 0.3))
		vbox.add_child(prog_label)
		if m["claimed"]:
			var done_label := Label.new()
			done_label.text = "✓ DONE"
			done_label.add_theme_font_size_override("font_size", 14)
			done_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
			done_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			hbox.add_child(done_label)
		elif m["completed"]:
			var claim_btn := Button.new()
			claim_btn.text = "+%d" % int(m["reward"])
			claim_btn.custom_minimum_size = Vector2(70, 36)
			claim_btn.add_theme_font_size_override("font_size", 14)
			claim_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			claim_btn.pressed.connect(_claim_mission.bind(m["id"]))
			hbox.add_child(claim_btn)
		content.add_child(card)
	var close := Button.new()
	close.text = "BACK"
	close.custom_minimum_size = Vector2(0, 55)
	close.add_theme_font_size_override("font_size", 22)
	close.pressed.connect(_close_overlay)
	content.add_child(close)


func _claim_mission(id: String) -> void:
	var reward := Missions.claim_reward(id)
	if reward > 0:
		Audio.play("powerup", -2.0)
		_close_overlay()
		_open_missions()


func _open_tutorial() -> void:
	if _shop_root != null:
		return
	_shop_root = CanvasLayer.new()
	_shop_root.layer = 20
	add_child(_shop_root)
	var dim := ColorRect.new()
	dim.color = Color(0.01, 0.01, 0.03, 0.92)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shop_root.add_child(dim)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 30
	scroll.offset_right = -30
	scroll.offset_top = 40
	scroll.offset_bottom = -40
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shop_root.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 16)
	scroll.add_child(content)
	_add_tut_title(content, "HOW TO PLAY")
	_add_tut_section(content, "MOVEMENT", "Touch and drag anywhere on the LEFT HALF of the screen. A neon joystick appears. Your spark follows where you point.")
	_add_tut_section(content, "SHOOTING", "Your weapon fires AUTOMATICALLY at the nearest enemy. Just focus on positioning.")
	_add_tut_section(content, "DASH", "Tap the DIAMOND button (bottom-right) to dash. Brief invincibility + speed. Cooldown shown by the ring.")
	_add_tut_section(content, "LEVELS", "Each level has a fixed enemy count. Kill all to clear. You heal +1 HP on every clear.")
	_add_tut_section(content, "WEAPONS", "Pick up CYAN CRATES for new weapons. Pulse Bolt (auto-target), Orbit Blades (spin + shoot), Nova Burst (shockwave + shoot). All fire automatically.")
	_add_tut_section(content, "POWERUPS", "MAGENTA = Overdrive (faster fire). WHITE = Shield (+1 HP). AMBER = Magnet (vacuum XP). All enhance shooting.")
	_add_tut_section(content, "GEMS", "Collect gems from kills and level clears. Spend in SHOP for permanent upgrades.")
	_add_tut_section(content, "RADAR", "Circular radar (top-left) shows enemy positions as colored dots.")
	_add_tut_section(content, "CARDS", "Gain XP to level up, then choose 1 of 3 random upgrade cards.")
	var close := Button.new()
	close.text = "GOT IT"
	close.custom_minimum_size = Vector2(0, 55)
	close.add_theme_font_size_override("font_size", 22)
	close.pressed.connect(_close_overlay)
	content.add_child(close)


func _add_tut_title(parent: Control, text: String) -> void:
	var t := Label.new()
	t.text = text
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 30)
	t.add_theme_color_override("font_color", Color(0.0, 0.94, 1.0))
	t.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	t.add_theme_constant_override("shadow_offset_y", 2)
	parent.add_child(t)


func _add_tut_section(parent: Control, title: String, desc: String) -> void:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.07, 0.14, 0.9)
	sb.border_color = Color(0.0, 0.94, 1.0, 0.3)
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", sb)
	parent.add_child(panel)
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)
	var t := Label.new()
	t.text = title
	t.add_theme_font_size_override("font_size", 18)
	t.add_theme_color_override("font_color", Color(0.0, 0.94, 1.0))
	vbox.add_child(t)
	var d := Label.new()
	d.text = desc
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.add_theme_font_size_override("font_size", 15)
	d.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
	vbox.add_child(d)


func _open_shop() -> void:
	if _shop_root != null:
		return
	var save := SaveSystem.load_save()
	var gems: int = int(save.get("gems", 0))
	var upgrades: Dictionary = save.get("upgrades", {})

	# Use CanvasLayer so it renders on top of everything
	_shop_root = CanvasLayer.new()
	_shop_root.layer = 20
	add_child(_shop_root)

	# Full-screen dim background
	var dim := ColorRect.new()
	dim.color = Color(0.01, 0.01, 0.03, 0.90)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shop_root.add_child(dim)

	# Main scroll container
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 30
	scroll.offset_right = -30
	scroll.offset_top = 40
	scroll.offset_bottom = -40
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shop_root.add_child(scroll)

	# Content VBox
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 14)
	scroll.add_child(content)

	# Title
	var t := Label.new()
	t.text = "UPGRADE SHOP"
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 30)
	t.add_theme_color_override("font_color", Color(1.0, 0.72, 0.0))
	t.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	t.add_theme_constant_override("shadow_offset_y", 2)
	content.add_child(t)

	# Gem balance
	var bal := Label.new()
	bal.name = "Balance"
	bal.text = "%d gems" % gems
	bal.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bal.add_theme_font_size_override("font_size", 22)
	bal.add_theme_color_override("font_color", Color(1.0, 0.72, 0.0))
	content.add_child(bal)

	# Upgrade cards
	for id: String in SaveSystem.UPGRADES:
		var def: Dictionary = SaveSystem.UPGRADES[id]
		var cur_lv: int = int(upgrades.get(id, 0))
		var max_lv: int = int(def["max"])
		var costs: Array = def["costs"]
		var at_max := cur_lv >= max_lv
		var cost: int = costs[cur_lv] if cur_lv < costs.size() else 0
		var can_buy := gems >= cost and not at_max
		content.add_child(_make_card(id, def["title"], def["desc"], cur_lv, max_lv, cost, can_buy))

	# Close button
	var close := Button.new()
	close.text = "BACK"
	close.custom_minimum_size = Vector2(0, 55)
	close.add_theme_font_size_override("font_size", 22)
	close.pressed.connect(_close_overlay)
	content.add_child(close)


func _make_card(id: String, title: String, desc: String, cur_lv: int, max_lv: int, cost: int, can_buy: bool) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 80)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.09, 0.18, 0.95)
	sb.border_color = Color(0.0, 0.94, 1.0, 0.5) if can_buy else Color(1, 1, 1, 0.15)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	card.add_theme_stylebox_override("panel", sb)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	card.add_child(hbox)

	# Left: text
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(vbox)

	var name_label := Label.new()
	name_label.text = "%s  Lv%d/%d" % [title, cur_lv, max_lv]
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = desc
	desc_label.add_theme_font_size_override("font_size", 14)
	desc_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	vbox.add_child(desc_label)

	# Right: action
	if cur_lv >= max_lv:
		var mx := Label.new()
		mx.text = "MAXED"
		mx.add_theme_font_size_override("font_size", 16)
		mx.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		mx.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hbox.add_child(mx)
	else:
		var btn := Button.new()
		btn.text = "BUY %d" % cost
		btn.custom_minimum_size = Vector2(90, 44)
		btn.add_theme_font_size_override("font_size", 16)
		btn.disabled = not can_buy
		btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		btn.pressed.connect(_buy.bind(id))
		hbox.add_child(btn)

	return card


func _buy(id: String) -> void:
	if SaveSystem.buy_upgrade(id):
		Audio.play("powerup", -2.0)
		_close_overlay()
		_open_shop()


func _close_overlay() -> void:
	if _shop_root != null:
		_shop_root.queue_free()
		_shop_root = null


func _open_level_map() -> void:
	if _shop_root != null:
		return
	var save := SaveSystem.load_save()
	var highest := int(save.get("highest_unlocked", 1))
	var stars: Dictionary = save.get("level_stars", {})
	const TOTAL_LEVELS := 30

	_shop_root = CanvasLayer.new()
	_shop_root.layer = 20
	add_child(_shop_root)
	var dim := ColorRect.new()
	dim.color = Color(0.01, 0.01, 0.03, 0.92)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shop_root.add_child(dim)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 20
	scroll.offset_right = -20
	scroll.offset_top = 40
	scroll.offset_bottom = -40
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shop_root.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	scroll.add_child(content)
	var title := Label.new()
	title.text = "LEVEL MAP"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color(0.0, 0.94, 1.0))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	title.add_theme_constant_override("shadow_offset_y", 2)
	content.add_child(title)
	var progress := Label.new()
	progress.text = "%d / %d levels unlocked" % [mini(highest, TOTAL_LEVELS), TOTAL_LEVELS]
	progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress.add_theme_font_size_override("font_size", 16)
	progress.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	content.add_child(progress)
	# Build level grid: 3 columns with biome headers
	var biome_names := {1: "THE PROMENADE", 11: "NEON SEWERS", 21: "SKY RUINS"}
	var biome_colors := {1: Color(0.0, 0.94, 1.0), 11: Color(0.3, 1.0, 0.2), 21: Color(0.8, 0.4, 1.0)}
	var row_hbox: HBoxContainer = null
	for i in range(TOTAL_LEVELS):
		var lv := i + 1
		# Add biome header at start of each biome
		if biome_names.has(lv):
			var hdr := Label.new()
			hdr.text = biome_names[lv]
			hdr.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			hdr.add_theme_font_size_override("font_size", 18)
			hdr.add_theme_color_override("font_color", biome_colors[lv])
			hdr.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
			hdr.add_theme_constant_override("shadow_offset_y", 1)
			content.add_child(hdr)
		if i % 3 == 0:
			row_hbox = HBoxContainer.new()
			row_hbox.add_theme_constant_override("separation", 10)
			row_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
			content.add_child(row_hbox)
		var unlocked := lv <= highest
		var star_count := int(stars.get(str(lv), 0))
		var node := _make_level_node(lv, unlocked, star_count)
		row_hbox.add_child(node)
	var close := Button.new()
	close.text = "BACK"
	close.custom_minimum_size = Vector2(0, 55)
	close.add_theme_font_size_override("font_size", 22)
	close.pressed.connect(_close_overlay)
	content.add_child(close)


func _make_level_node(lv: int, unlocked: bool, star_count: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(100, 90)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb := StyleBoxFlat.new()
	if unlocked:
		sb.bg_color = Color(0.08, 0.12, 0.22, 0.95)
		sb.border_color = Color(0.0, 0.94, 1.0, 0.6) if star_count > 0 else Color(1, 1, 1, 0.2)
	else:
		sb.bg_color = Color(0.04, 0.04, 0.08, 0.8)
		sb.border_color = Color(1, 1, 1, 0.08)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(12)
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", sb)
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)
	var num := Label.new()
	num.text = str(lv)
	num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num.add_theme_font_size_override("font_size", 24)
	num.add_theme_color_override("font_color", Color.WHITE if unlocked else Color(1, 1, 1, 0.2))
	vbox.add_child(num)
	var stars_text := ""
	if unlocked:
		for s in range(3):
			stars_text += "★" if s < star_count else "☆"
	else:
		stars_text = "🔒"
	var star_label := Label.new()
	star_label.text = stars_text
	star_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	star_label.add_theme_font_size_override("font_size", 14)
	star_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0) if star_count > 0 else Color(1, 1, 1, 0.3))
	vbox.add_child(star_label)
	if unlocked:
		panel.gui_input.connect(_on_level_tap.bind(lv))
	return panel


func _on_level_tap(event: InputEvent, lv: int) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_close_overlay()
		_start_level(lv)


func _start_level(lv: int) -> void:
	RunState.reset_run(lv)
	GameState.change_state(GameState.State.RUN)
	get_tree().change_scene_to_file("res://scenes/arena.tscn")


func _spawn_spark(at: Vector2) -> void:
	var p := CPUParticles2D.new()
	p.position = at
	p.one_shot = true
	p.emitting = true
	p.amount = 24
	p.lifetime = 0.7
	p.explosiveness = 1.0
	p.spread = 180.0
	p.gravity = Vector2.ZERO
	p.initial_velocity_min = 60.0
	p.initial_velocity_max = 220.0
	p.scale_amount_min = 2.0
	p.scale_amount_max = 5.0
	p.color = Color(0.0, 0.94, 1.0) if randi() % 2 == 0 else Color(1.0, 0.18, 0.53)
	add_child(p)
	get_tree().create_timer(1.6).timeout.connect(p.queue_free)
