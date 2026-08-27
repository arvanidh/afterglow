class_name RunHud
extends CanvasLayer
## In-run HUD v2: timer, level tracker, XP bar, combo meter, HP pips,
## gun badge, powerup timers, dash button with cooldown ring, banner system,
## level-up draft overlay, floating damage numbers, results panel.
## Runs in PROCESS_MODE_ALWAYS so drafts stay interactive while the sim pauses.

const CYAN := Color(0.0, 0.94, 1.0)
const DIM := Color(1, 1, 1, 0.45)
const AMBER := Color(1.0, 0.72, 0.0)
const MAGENTA := Color(1.0, 0.18, 0.53)

var time_label: Label
var level_label: Label
var kills_label: Label
var motes_label: Label
var gems_label: Label
var gun_label: Label
var powerup_label: Label
var combo_label: Label
var hp_box: HBoxContainer
var vignette: ColorRect
var _banner: Label
var _xp_fill: ColorRect
var _xp_bg: ColorRect
var _dash_btn: Control
var _dash_frac := -1.0  # <0 hidden
var _draft_root: Control
var _radar: Control
var _radar_enemies: Array = []
var _floats: Array[Label] = []
var _announcer_base_y := 0.0
var _pause_overlay: Control
var _pause_btn: Label
var camera: Camera2D
var _boss_bar: ColorRect
var _boss_bar_bg: ColorRect
var _boss_name_label: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_vignette()

	time_label = _label("0:00", 34, CYAN)
	_anchor(time_label, 0.5, 0.0, -90, 90, 14, 62)
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label = _label("LEVEL 1", 15, DIM)
	_anchor(level_label, 0.5, 0.0, -120, 120, 64, 86)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	combo_label = _label("", 22, AMBER)
	_anchor(combo_label, 0.5, 0.0, -120, 120, 88, 118)
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	combo_label.pivot_offset = Vector2(120, 15)

	kills_label = _label("", 20, DIM)
	_anchor(kills_label, 0.0, 0.0, 16, 260, 16, 44)
	motes_label = _label("◆ 0", 20, AMBER)
	_anchor(motes_label, 1.0, 0.0, -140, -16, 16, 44)
	motes_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	gems_label = _label("◆ 0", 18, Color(1.0, 0.72, 0.0))
	_anchor(gems_label, 1.0, 0.0, -140, -16, 46, 70)
	gems_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	gun_label = _label("PULSE BOLT", 17, Color(CYAN.r, CYAN.g, CYAN.b, 0.85))
	_anchor(gun_label, 1.0, 1.0, -240, -16, -46, -20)
	gun_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	powerup_label = _label("", 18, MAGENTA)
	_anchor(powerup_label, 1.0, 1.0, -260, -16, -76, -50)
	powerup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	hp_box = HBoxContainer.new()
	hp_box.add_theme_constant_override("separation", 8)
	_anchor(hp_box, 0.5, 1.0, -110, 110, -40, -18)
	hp_box.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(hp_box)

	_build_xp_bar()
	_build_dash_button()
	_build_radar()

	_banner = Label.new()
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner.add_theme_font_size_override("font_size", 46)
	_banner.add_theme_color_override("font_color", CYAN)
	_banner.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	_banner.add_theme_constant_override("shadow_offset_y", 3)
	_anchor(_banner, 0.5, 0.35, -320, 320, -40, 40)
	_banner.modulate.a = 0.0
	add_child(_banner)


# ---------------------------------------------------------------- builders

func _build_vignette() -> void:
	var layer_v := CanvasLayer.new()
	layer_v.layer = 5
	add_child(layer_v)
	vignette = ColorRect.new()
	vignette.color = Color(1.0, 0.05, 0.25, 0.0)
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer_v.add_child(vignette)


func _build_xp_bar() -> void:
	_xp_bg = ColorRect.new()
	_xp_bg.color = Color(0.0, 0.94, 1.0, 0.08)
	_anchor(_xp_bg, 0.0, 1.0, 24, -24, -56, -50)
	_xp_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_xp_bg)
	_xp_fill = ColorRect.new()
	_xp_fill.color = Color(0.0, 0.94, 1.0, 0.75)
	_xp_fill.anchor_top = 0.0
	_xp_fill.anchor_bottom = 1.0
	_xp_fill.anchor_left = 0.0
	_xp_fill.anchor_right = 0.0
	_xp_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_xp_bg.add_child(_xp_fill)


func _build_dash_button() -> void:
	_dash_btn = Control.new()
	_dash_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_dash_btn)
	_dash_btn.draw.connect(_draw_dash_button)
	_dash_btn.gui_input.connect(_on_dash_input)


func layout_dash_button(vsz: Vector2) -> void:
	if vsz.x <= 0.0:
		return
	var r := 52.0
	_dash_btn.position = Vector2(vsz.x - r * 2.0 - 26.0, vsz.y - r * 2.0 - 150.0)
	_dash_btn.size = Vector2(r * 2.0, r * 2.0)


func set_camera(cam: Camera2D) -> void:
	camera = cam


func _on_dash_input(ev: InputEvent) -> void:
	if ev is InputEventScreenTouch and ev.pressed:
		dash_requested.emit()
	elif ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		dash_requested.emit()


signal dash_requested


func _draw_dash_button() -> void:
	var c := _dash_btn.size * 0.5
	var r := 44.0
	var ready_col := Color(0.0, 0.94, 1.0, 0.9)
	if _dash_frac < 0.0:
		_dash_btn.draw_arc(c, r, 0.0, TAU, 40, ready_col, 3.0)
		_dash_btn.draw_circle(c, r - 8.0, Color(0.0, 0.94, 1.0, 0.10))
	else:
		_dash_btn.draw_arc(c, r, 0.0, TAU, 40, Color(1, 1, 1, 0.12), 3.0)
		if _dash_frac > 0.0:
			_dash_btn.draw_arc(c, r, -PI / 2.0, -PI / 2.0 + TAU * (1.0 - _dash_frac), 40, Color(CYAN.r, CYAN.g, CYAN.b, 0.55), 3.0)
	# diamond glyph
	var pts := PackedVector2Array([c + Vector2(0, -13), c + Vector2(11, 0), c + Vector2(0, 13), c + Vector2(-11, 0)])
	var glow := 0.95 if _dash_frac < 0.0 else 0.35
	_dash_btn.draw_colored_polygon(pts, Color(0.75, 1.0, 1.0, glow))


func tick_dash(frac: float) -> void:
	# frac<0 → ready (full glow); 0..1 → cooling
	if is_equal_approx(frac, _dash_frac):
		return
	_dash_frac = frac
	_dash_btn.queue_redraw()



	# ----- pause button + overlay
func layout_pause_button(vsz: Vector2) -> void:
	var pause_layer := CanvasLayer.new()
	_pause_btn = Label.new()
	_pause_btn.text = "||"
	_pause_btn.add_theme_font_size_override("font_size", 28)
	_pause_btn.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
	_pause_btn.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_pause_btn.add_theme_constant_override("shadow_offset_y", 2)
	_pause_btn.position = Vector2(vsz.x - 56, 30)
	_pause_btn.size = Vector2(44, 44)
	_pause_btn.z_index = 25
	_pause_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_pause_btn.gui_input.connect(_on_pause_input)
	pause_layer.add_child(_pause_btn)
	add_child(pause_layer)

func _on_pause_input(ev: InputEvent) -> void:
	if ev is InputEventScreenTouch and ev.pressed:
		toggle_pause()
	elif ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		toggle_pause()

signal pause_toggled(paused: bool)

func toggle_pause() -> void:
	var tree := get_tree()
	if tree.paused:
		tree.paused = false
		_hide_pause_overlay()
		pause_toggled.emit(false)
	else:
		tree.paused = true
		_show_pause_overlay()
		pause_toggled.emit(true)

var _pause_resume_rect := Rect2()
var _pause_quit_rect := Rect2()

func _show_pause_overlay() -> void:
	if _pause_overlay != null:
		_pause_overlay.queue_free()
	_pause_overlay = Control.new()
	_pause_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	var layer := CanvasLayer.new()
	layer.layer = 22
	layer.add_child(_pause_overlay)
	add_child(layer)
	# Dim
	var dim := ColorRect.new()
	dim.color = Color(0.01, 0.01, 0.03, 0.78)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pause_overlay.add_child(dim)
	# PAUSED title
	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", CYAN)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	title.set_anchors_preset(Control.PRESET_CENTER)
	title.offset_top = -120
	title.offset_bottom = -60
	title.offset_left = -150
	title.offset_right = 150
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pause_overlay.add_child(title)
	# RESUME
	var resume := _make_pause_btn("RESUME", CYAN, -30)
	_pause_overlay.add_child(resume)
	# QUIT TO MENU
	var quitb := _make_pause_btn("QUIT TO MENU", Color(1.0, 0.45, 0.2), 60)
	_pause_overlay.add_child(quitb)
	# Store button rects for _input hit-testing
	var vsz := get_viewport().get_visible_rect().size
	var cx := vsz.x * 0.5
	var cy := vsz.y * 0.5
	_pause_resume_rect = Rect2(cx - 150, cy - 30, 300, 55)
	_pause_quit_rect = Rect2(cx - 150, cy + 60, 300, 55)


func _input(event: InputEvent) -> void:
	# Only handle pause overlay taps when paused
	if get_tree() == null or not get_tree().paused:
		return
	if _pause_overlay == null:
		return
	var pos := Vector2.ZERO
	var pressed := false
	if event is InputEventScreenTouch:
		pos = event.position
		pressed = event.pressed
	elif event is InputEventMouseButton:
		pos = event.position
		pressed = event.pressed
	if not pressed:
		return
	if _pause_resume_rect.has_point(pos):
		toggle_pause()
	elif _pause_quit_rect.has_point(pos):
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/boot.tscn")

func _hide_pause_overlay() -> void:
	if _pause_overlay != null:
		_pause_overlay.queue_free()
		_pause_overlay = null
	_pause_resume_rect = Rect2()
	_pause_quit_rect = Rect2()

func _make_pause_btn(text: String, col: Color, y_off: float) -> ColorRect:
	var container := ColorRect.new()
	container.color = Color(col.r, col.g, col.b, 0.15)
	container.set_anchors_preset(Control.PRESET_CENTER)
	container.offset_top = y_off
	container.offset_bottom = y_off + 55
	container.offset_left = -150
	container.offset_right = 150
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 30)
	lbl.add_theme_color_override("font_color", col)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.add_child(lbl)
	return container

func combo_pop(streak: int) -> void:
	# Scale text size with combo: bigger combos = bigger text
	var base_size := 22
	var size_boost := mini(streak / 5, 6)
	combo_label.add_theme_font_size_override("font_size", base_size + size_boost * 3)
	combo_label.text = "×%d COMBO" % streak
	# Color shifts from amber to magenta to cyan at high combos
	if streak >= 30:
		combo_label.add_theme_color_override("font_color", Color(0.0, 1.0, 1.0))
	elif streak >= 20:
		combo_label.add_theme_color_override("font_color", Color(1.0, 0.0, 0.6))
	elif streak >= 10:
		combo_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.1))
	else:
		combo_label.add_theme_color_override("font_color", AMBER)
	combo_label.scale = Vector2(1.6, 1.6)
	var tw := create_tween()
	tw.tween_property(combo_label, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK)


func clear_combo() -> void:
	combo_label.text = ""

var _announcer_label: Label

func _build_announcer() -> void:
	_announcer_label = Label.new()
	_announcer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_announcer_label.z_index = 30
	_announcer_label.visible = false
	_announcer_label.add_theme_font_size_override("font_size", 38)
	_announcer_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	_announcer_label.add_theme_constant_override("shadow_offset_x", 2)
	_announcer_label.add_theme_constant_override("shadow_offset_y", 2)
	var _vsz := get_viewport().get_visible_rect().size
	_announcer_label.position = Vector2(_vsz.x * 0.5 - 200, _vsz.y * 0.32)
	_announcer_label.size = Vector2(400, 50)
	_announcer_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_announcer_label)
	_announcer_base_y = _announcer_label.position.y

func show_announcer(text: String, col: Color) -> void:
	if _announcer_label == null or not is_instance_valid(_announcer_label):
		_build_announcer()
	if not is_instance_valid(_announcer_label):
		return
	_kill_announcer_tweens()
	_announcer_label.text = text
	_announcer_label.add_theme_color_override("font_color", col)
	_announcer_label.visible = true
	_announcer_label.modulate.a = 1.0
	_announcer_label.scale = Vector2(1.8, 1.8)
	_announcer_label.pivot_offset = Vector2(200, 25)
	# Reset position to base each time (prevents upward drift)
	_announcer_label.position.y = _announcer_base_y
	var tw := create_tween()
	tw.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tw.tween_property(_announcer_label, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_announcer_label, "position:y", _announcer_base_y - 20.0, 0.6).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.5)
	tw.tween_property(_announcer_label, "modulate:a", 0.0, 0.3)
	tw.tween_callback(func(): _announcer_label.visible = false)

func _kill_announcer_tweens() -> void:
	if _announcer_label == null:
		return
	var tweens := _announcer_label.get_meta("_tweens", []) as Array
	for t in tweens:
		if is_instance_valid(t) and t.is_valid():
			t.kill()
	_announcer_label.set_meta("_tweens", [])

# ---------------------------------------------------------------- standard API

func show_banner(text: String, col: Color, hold := 1.1) -> void:
	if _banner == null or not is_instance_valid(_banner):
		return
	_banner.text = text
	_banner.add_theme_color_override("font_color", col)
	var tw := create_tween()
	tw.tween_property(_banner, "modulate:a", 1.0, 0.18)
	tw.tween_interval(hold)
	tw.tween_property(_banner, "modulate:a", 0.0, 0.45)


func set_level(n: int, remaining: int) -> void:
	level_label.text = "LEVEL %d  ·  %d left" % [n, remaining]


func set_gun(display_name: String, lv: int) -> void:
	gun_label.text = "%s · Lv%d" % [display_name.to_upper(), lv]


func set_powerup(text: String) -> void:
	powerup_label.text = text


func set_xp(frac: float, plevel: int) -> void:
	_xp_fill.anchor_right = clampf(frac, 0.0, 1.0)

func set_gems(amount: int) -> void:
	gems_label.text = "◆ %d" % amount

func tick(run_time: float) -> void:
	var m := int(run_time) / 60
	var s := int(run_time) % 60
	time_label.text = "%d:%02d" % [m, s]
	motes_label.text = "◆ %d" % RunState.shards


func refresh_hp(effective_max: int) -> void:
	for child in hp_box.get_children():
		child.queue_free()
	for i in range(effective_max):
		var pip := ColorRect.new()
		pip.custom_minimum_size = Vector2(16, 10)
		pip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		pip.color = CYAN if i < RunState.hp else Color(1, 1, 1, 0.12)
		hp_box.add_child(pip)


func show_boss_bar(boss_name: String) -> void:
	if _boss_bar != null:
		return
	# Boss name label
	_boss_name_label = Label.new()
	_boss_name_label.text = boss_name
	_boss_name_label.add_theme_font_size_override("font_size", 16)
	_boss_name_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.1))
	_boss_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_name_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_boss_name_label.offset_left = -150
	_boss_name_label.offset_right = 150
	_boss_name_label.offset_top = 90
	_boss_name_label.offset_bottom = 115
	add_child(_boss_name_label)
	# Bar background
	_boss_bar_bg = ColorRect.new()
	_boss_bar_bg.color = Color(0.1, 0.1, 0.1, 0.8)
	_boss_bar_bg.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_boss_bar_bg.offset_left = -140
	_boss_bar_bg.offset_right = 140
	_boss_bar_bg.offset_top = 112
	_boss_bar_bg.offset_bottom = 122
	add_child(_boss_bar_bg)
	# Bar fill
	_boss_bar = ColorRect.new()
	_boss_bar.color = Color(1.0, 0.3, 0.1)
	_boss_bar.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_boss_bar.offset_left = -140
	_boss_bar.offset_right = 140
	_boss_bar.offset_top = 112
	_boss_bar.offset_bottom = 122
	add_child(_boss_bar)


func update_boss_bar(hp: int, max_hp: int) -> void:
	if _boss_bar == null:
		return
	var frac := float(hp) / float(max_hp)
	_boss_bar.offset_right = -140 + 280.0 * frac
	if frac > 0.5:
		_boss_bar.color = Color(1.0, 0.3, 0.1)
	elif frac > 0.25:
		_boss_bar.color = Color(1.0, 0.8, 0.2)
	else:
		_boss_bar.color = Color(1.0, 0.1, 0.1)


func hide_boss_bar() -> void:
	if _boss_bar != null:
		_boss_bar.queue_free()
		_boss_bar = null
	if _boss_bar_bg != null:
		_boss_bar_bg.queue_free()
		_boss_bar_bg = null
	if _boss_name_label != null:
		_boss_name_label.queue_free()
		_boss_name_label = null


func flash_damage() -> void:
	vignette.color = Color(0.9, 0.15, 0.1, 0.35)


func flash_kill() -> void:
	if vignette == null or not is_instance_valid(vignette):
		return
	vignette.color = Color(1.0, 1.0, 1.0, 0.18)


func flash_level_up() -> void:
	if vignette == null or not is_instance_valid(vignette):
		return
	vignette.color = Color(0.0, 0.94, 1.0, 0.25)


func fade_vignette(delta: float) -> void:
	if vignette == null or not is_instance_valid(vignette):
		return
	vignette.color.a = maxf(0.0, vignette.color.a - delta * 2.5)


# ---------------------------------------------------------------- damage numbers

func spawn_float(world_pos: Vector2, text: String, col: Color) -> void:
	if camera == null:
		return
	var vsz := get_viewport().get_visible_rect().size
	var screen := world_pos - camera.get_screen_center_position() + vsz * 0.5
	if screen.x < -40 or screen.y < -40 or screen.x > vsz.x + 40 or screen.y > vsz.y + 40:
		return
	# Cap floating labels to prevent buildup
	while _floats.size() > 30:
		var old_l: Label = _floats.pop_front()
		if is_instance_valid(old_l):
			old_l.queue_free()
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 20)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	l.position = screen + Vector2(randf_range(-10, 10), -18)
	l.z_index = 30
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	_floats.append(l)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.set_process_mode(Tween.TWEEN_PROCESS_IDLE)
	tw.tween_property(l, "position:y", l.position.y - 34.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(func():
		if is_instance_valid(l):
			_floats.erase(l)
			l.queue_free()
	)


# ---------------------------------------------------------------- level-up draft

func show_draft(choices: Array, on_pick: Callable) -> void:
	if _draft_root != null:
		_draft_root.queue_free()
	_draft_root = Control.new()
	_draft_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_draft_root)

	var dim := ColorRect.new()
	dim.color = Color(0.01, 0.01, 0.03, 0.72)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_draft_root.add_child(dim)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 22)
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	_draft_root.add_child(box)

	var title := Label.new()
	title.text = "LEVEL UP  ·  CHOOSE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", AMBER)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	box.add_child(title)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(row)

	for card: Dictionary in choices:
		row.add_child(_make_card(card, on_pick))


func _make_card(card: Dictionary, on_pick: Callable) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(190, 250)
	b.focus_mode = Control.FOCUS_NONE
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.06, 0.12, 0.98)
	sb.set_corner_radius_all(14)
	sb.set_border_width_all(2)
	var rc: Color = CardDb.RARITY_COLORS[card["rarity"]]
	sb.border_color = rc
	b.add_theme_stylebox_override("normal", sb)
	var sbh := sb.duplicate()
	sbh.bg_color = Color(0.09, 0.11, 0.2, 1.0)
	b.add_theme_stylebox_override("hover", sbh)
	var sbp := sb.duplicate()
	sbp.bg_color = Color(0.02, 0.03, 0.07, 1.0)
	b.add_theme_stylebox_override("pressed", sbp)

	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 12)
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.offset_left = 12
	v.offset_right = -12
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(v)

	var rar := Label.new()
	rar.text = ["COMMON", "UNCOMMON", "RARE", "EPIC"][card["rarity"]]
	rar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rar.add_theme_font_size_override("font_size", 12)
	rar.add_theme_color_override("font_color", rc)
	v.add_child(rar)

	var t := Label.new()
	t.text = String(card["title"])
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	t.add_theme_font_size_override("font_size", 21)
	t.add_theme_color_override("font_color", Color.WHITE)
	v.add_child(t)

	var d := Label.new()
	d.text = String(card["desc"])
	d.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.add_theme_font_size_override("font_size", 15)
	d.add_theme_color_override("font_color", DIM)
	v.add_child(d)

	b.pressed.connect(func() -> void:
		Audio.play("select")
		if _draft_root != null:
			_draft_root.queue_free()
			_draft_root = null
		on_pick.call(card))
	return b




# ---------------------------------------------------------------- radar minimap

func _build_radar() -> void:
	_radar = Control.new()
	_radar.custom_minimum_size = Vector2(110, 110)
	_radar.size = Vector2(110, 110)
	_radar.position = Vector2(16, 50)
	_radar.z_index = 15
	_radar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_radar.draw.connect(_draw_radar)
	add_child(_radar)


func update_radar(enemies: Array, player_pos: Vector2) -> void:
	if not Settings.show_radar:
		_radar.visible = false
		return
	_radar.visible = true
	_radar_enemies = enemies
	_radar.queue_redraw()


func _draw_radar() -> void:
	var center := Vector2(55, 55)
	var radius := 50.0
	# Background circle
	_radar.draw_circle(center, radius, Color(0.0, 0.0, 0.0, 0.6))
	_radar.draw_arc(center, radius, 0.0, TAU, 32, Color(0.0, 0.94, 1.0, 0.3), 1.5)
	# Grid lines
	_radar.draw_line(Vector2(center.x - radius, center.y), Vector2(center.x + radius, center.y), Color(0.0, 0.94, 1.0, 0.1), 1.0)
	_radar.draw_line(Vector2(center.x, center.y - radius), Vector2(center.x, center.y + radius), Color(0.0, 0.94, 1.0, 0.1), 1.0)
	# Player dot (center, bright cyan)
	_radar.draw_circle(center, 4.0, Color(0.0, 0.94, 1.0, 0.9))
	# Enemy dots
	var scale := radius / 400.0  # 400px game range = full radar
	for e in _radar_enemies:
		if not e.active:
			continue
		var diff: Vector2 = e.global_position - (camera.get_screen_center_position() if camera else Vector2.ZERO)
		var pos := center + diff * scale
		if pos.distance_to(center) > radius - 3.0:
			continue  # Off radar
		var col: Color = ShadowEnemy.STATS[e.kind]["eye"] if ShadowEnemy.STATS.has(e.kind) else Color.RED
		_radar.draw_circle(pos, 2.5, Color(col.r, col.g, col.b, 0.8))

# ---------------------------------------------------------------- results

func build_results(survived: float, seed_hex: String, level_reached: int, is_victory: bool = false) -> Control:
	# Funny death messages or victory
	var death_msgs := [
		"THE LIGHT WENT OUT",
		"SCREENED BY A SHADOW",
		"THE DARKNESS WINS... AGAIN",
		"RAN OUT OF SPARKS",
		"OOPS, ALL SHADOWS",
		"THE CITY STAYS BLACK",
		"SHADOW 1, LIGHT 0",
		"YOUR SPARK GOT SNuffed",
		"TOO MANY SHADOWS, NOT ENOUGH GLOW",
		"THE DARKNESS SENDS ITS REGARDS",
		"YOU DIED DOING WHAT YOU LOVED: SHOOTING",
		"THE SHADOWS SEND THEIR THOUGHTS AND PRAYERS",
		"A SHADOW WROTE YOUR NAME IN THE DARK",
		"YOUR LIGHT BILL IS DUE",
		"THE DARKNESS SUBSCRIBED TO YOUR CHANNEL",
		"THE SHADOWS APPRECIATE YOUR CONTRIBUTION",
		"THE DARKNESS TYPED 'GG' IN CHAT",
		"YOUR SPARK JUST UNPLUGGED ITSELF",
		"THE SHADOWS THOUGHT YOU WERE THE BOSS",
		"YOUR LIGHT JUST RAN OUT OF BATTERY",
		"THE DARKNESS POSTED YOUR L ON TWITTER",
		"YOUR SPARK IS NOW A GHOST LIGHT",
		"THE SHADOWS JUST HIT YOU WITH THE WET FLOOR SIGN",
		"YOUR LIGHT JUST DID A BACKFLIP OFF A CLIFF",
		"THE DARKNESS JUST DABBED ON YOUR GRAVE",
	]
	var victory_msgs := [
		"THE DARKNESS IS GONE",
		"THE CITY SHINES AGAIN",
		"YOU ARE THE LIGHT",
		"OUTSHINED THEM ALL",
		"TOTAL VICTORY",
	]
	var msg: String
	if is_victory:
		msg = victory_msgs[randi() % victory_msgs.size()]
	else:
		msg = death_msgs[randi() % death_msgs.size()]

	# Star rating
	var star_count := 1
	if RunState.deaths == 0:
		star_count = 3
	elif RunState.deaths <= 1:
		star_count = 2
	var stars_text := ""
	for i in range(3):
		stars_text += "★" if i < star_count else "☆"

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.process_mode = Node.PROCESS_MODE_ALWAYS

	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.043, 0.055, 0.102, 0.96)
	sb.border_color = Color(CYAN.r, CYAN.g, CYAN.b, 0.55)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(18)
	sb.content_margin_left = 42
	sb.content_margin_right = 42
	sb.content_margin_top = 30
	sb.content_margin_bottom = 30
	panel.add_theme_stylebox_override("panel", sb)
	center.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)

	var m := int(survived) / 60
	var s := int(survived) % 60

	# Funny death message
	box.add_child(_res_label(msg, 22, MAGENTA))
	# Stars
	var star_label := _res_label(stars_text, 30, Color(1.0, 0.85, 0.0))
	box.add_child(star_label)
	box.add_child(_res_label(" ", 4, DIM))
	# Stats grid
	box.add_child(_res_label("LEVEL %d  ·  %d:%02d" % [level_reached, m, s], 20, Color.WHITE))
	box.add_child(_res_label("%d kills  ·  %d gems earned" % [RunState.kills, RunState.gems_earned], 16, DIM))
	box.add_child(_res_label("%d deaths  ·  ◆ %d shards" % [RunState.deaths, RunState.shards], 16, DIM))
	box.add_child(_res_label(" ", 6, DIM))
	box.add_child(_res_label("+%d GEMS" % RunState.gems_earned, 28, AMBER))
	box.add_child(_res_label("seed %s" % seed_hex, 12, Color(1, 1, 1, 0.25)))
	box.add_child(_res_label(" ", 8, DIM))

	# Retry button
	var retry := Button.new()
	retry.text = "RETRY"
	retry.custom_minimum_size = Vector2(200, 50)
	retry.add_theme_font_size_override("font_size", 22)
	retry.pressed.connect(_on_retry)
	box.add_child(retry)

	# Menu button
	var menu_btn := Button.new()
	menu_btn.text = "MENU"
	menu_btn.custom_minimum_size = Vector2(200, 50)
	menu_btn.add_theme_font_size_override("font_size", 18)
	menu_btn.pressed.connect(_on_menu)
	box.add_child(menu_btn)

	# Share card button
	var share := Button.new()
	share.text = "SHARE RUN"
	share.custom_minimum_size = Vector2(200, 50)
	share.add_theme_font_size_override("font_size", 16)
	share.pressed.connect(_on_share.bind(level_reached, survived, RunState.kills, RunState.gems_earned, star_count))
	box.add_child(share)

	add_child(center)
	return center


func _on_retry() -> void:
	# Restart the same level
	RunState.reset_run(RunState.start_level)
	GameState.change_state(GameState.State.RUN)
	get_tree().change_scene_to_file("res://scenes/arena.tscn")


func _on_menu() -> void:
	GameState.change_state(GameState.State.MENU)
	get_tree().change_scene_to_file("res://scenes/boot.tscn")


func _on_share(lv: int, time: float, kills: int, gems: int, stars: int) -> void:
	# Build shareable text card
	var m := int(time) / 60
	var s := int(time) % 60
	var stars_text := ""
	for i in range(3):
		stars_text += "★" if i < stars else "☆"
	var text := "⚡ AFTERGLOW — Run Report\n"
	text += "%s Level %d\n" % [stars_text, lv]
	text += "%d:%02d · %d kills · %d gems\n" % [m, s, kills, gems]
	text += "Can you outshine me? 🌟"
	# Copy to clipboard on Android
	if DisplayServer.clipboard_has():
		DisplayServer.clipboard_set(text)
	else:
		DisplayServer.clipboard_set(text)
	# Show confirmation
	_show_share_confirm()


func _show_share_confirm() -> void:
	# Brief "Copied!" popup
	var popup := Label.new()
	popup.text = "✓ COPIED TO CLIPBOARD — PASTE IN CHAT!"
	popup.add_theme_font_size_override("font_size", 16)
	popup.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.set_anchors_preset(Control.PRESET_CENTER)
	popup.offset_left = -160
	popup.offset_right = 160
	popup.offset_top = -20
	popup.offset_bottom = 20
	add_child(popup)
	var tw := popup.create_tween()
	tw.tween_interval(1.5)
	tw.tween_property(popup, "modulate:a", 0.0, 0.3)
	tw.tween_callback(popup.queue_free)


func _res_label(text: String, size: int, col: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	return l


func _anchor(c: Control, ax: float, ay: float, ox: int, ox2: int, oy: int, oy2: int) -> void:
	c.anchor_left = ax
	c.anchor_right = ax
	c.anchor_top = ay
	c.anchor_bottom = ay
	c.offset_left = ox
	c.offset_right = ox2
	c.offset_top = oy
	c.offset_bottom = oy2


func _label(text: String, size: int, col: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	l.add_theme_constant_override("shadow_offset_y", 2)
	add_child(l)
	return l
