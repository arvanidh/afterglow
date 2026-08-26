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
var camera: Camera2D


func _ready() -> void:
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


func combo_pop(streak: int) -> void:
	combo_label.text = "×%d COMBO" % streak
	combo_label.scale = Vector2(1.5, 1.5)
	var tw := create_tween()
	tw.tween_property(combo_label, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK)


func clear_combo() -> void:
	combo_label.text = ""


# ---------------------------------------------------------------- standard API

func show_banner(text: String, col: Color, hold := 1.1) -> void:
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


func flash_damage() -> void:
	vignette.color.a = 0.38


func fade_vignette(delta: float) -> void:
	vignette.color.a = maxf(0.0, vignette.color.a - delta * 1.4)


# ---------------------------------------------------------------- damage numbers

func spawn_float(world_pos: Vector2, text: String, col: Color) -> void:
	if camera == null:
		return
	var vsz := get_viewport().get_visible_rect().size
	var screen := world_pos - camera.get_screen_center_position() + vsz * 0.5
	if screen.x < -40 or screen.y < -40 or screen.x > vsz.x + 40 or screen.y > vsz.y + 40:
		return
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 20)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	l.position = screen + Vector2(randf_range(-10, 10), -18)
	l.z_index = 30
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(l)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "position:y", l.position.y - 34.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(l, "modulate:a", 0.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(l.queue_free)


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


# ---------------------------------------------------------------- results

func build_results(survived: float, seed_hex: String, level_reached: int) -> Control:
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
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)

	var m := int(survived) / 60
	var s := int(survived) % 60

	box.add_child(_res_label("THE LIGHT WENT OUT", 26, MAGENTA))
	box.add_child(_res_label("reached LEVEL %d  ·  survived %d:%02d" % [level_reached, m, s], 22, Color.WHITE))
	box.add_child(_res_label("%d shadows dispelled   ·   ◆ %d collected" % [RunState.kills, RunState.shards], 16, DIM))
	box.add_child(_res_label(" ", 6, DIM))
	box.add_child(_res_label("+%d SHARDS" % RunState.shards, 32, AMBER))
	box.add_child(_res_label("seed %s" % seed_hex, 13, Color(1, 1, 1, 0.3)))
	box.add_child(_res_label(" ", 6, DIM))
	var cta := _res_label("touch to surface", 16, CYAN)
	box.add_child(cta)
	var tw := cta.create_tween().set_loops()
	tw.tween_property(cta, "modulate:a", 0.3, 0.7)
	tw.tween_property(cta, "modulate:a", 1.0, 0.7)

	add_child(center)
	return center


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
