class_name RunHud
extends CanvasLayer
## In-run HUD (§6): timer top-center, kills left, motes right, HP pips bottom.
## Also owns the damage vignette and the results panel. Safe-area friendly:
## all elements keep ≥16px insets.

const CYAN := Color(0.0, 0.94, 1.0)
const DIM := Color(1, 1, 1, 0.45)
const AMBER := Color(1.0, 0.72, 0.0)

var time_label: Label
var kills_label: Label
var motes_label: Label
var hp_box: HBoxContainer
var vignette: ColorRect


func _ready() -> void:
	layer = 10
	_build_vignette()
	time_label = _label("0:00", 34, CYAN)
	_anchor(time_label, 0.5, 0.0, -90, 90, 14, 62)
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	kills_label = _label("0 shades", 20, DIM)
	_anchor(kills_label, 0.0, 0.0, 16, 260, 16, 44)
	motes_label = _label("◆ 0", 20, AMBER)
	_anchor(motes_label, 1.0, 0.0, -140, -16, 16, 44)
	motes_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hp_box = HBoxContainer.new()
	hp_box.add_theme_constant_override("separation", 8)
	_anchor(hp_box, 0.5, 1.0, -110, 110, -40, -18)
	hp_box.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(hp_box)
	refresh_hp()


func _build_vignette() -> void:
	var layer_v := CanvasLayer.new()
	layer_v.layer = 5
	add_child(layer_v)
	vignette = ColorRect.new()
	vignette.color = Color(1.0, 0.05, 0.25, 0.0)
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer_v.add_child(vignette)


func _label(text: String, size: int, col: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	l.add_theme_constant_override("shadow_offset_y", 2)
	add_child(l)
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


func tick(run_time: float) -> void:
	var m := int(run_time) / 60
	var s := int(run_time) % 60
	time_label.text = "%d:%02d" % [m, s]
	kills_label.text = "%d shades" % RunState.kills
	motes_label.text = "◆ %d" % RunState.shards


func refresh_hp() -> void:
	for child in hp_box.get_children():
		child.queue_free()
	for i in range(RunState.max_hp):
		var pip := ColorRect.new()
		pip.custom_minimum_size = Vector2(16, 10)
		pip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		pip.color = CYAN if i < RunState.hp else Color(1, 1, 1, 0.12)
		hp_box.add_child(pip)


func flash_damage() -> void:
	vignette.color.a = 0.38


func fade_vignette(delta: float) -> void:
	vignette.color.a = maxf(0.0, vignette.color.a - delta * 1.4)


func build_results(survived: float, seed_hex: String) -> Control:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE

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
	var payout := RunState.shards

	box.add_child(_res_label("THE LIGHT WENT OUT", 26, Color(1.0, 0.18, 0.53)))
	box.add_child(_res_label("survived %d:%02d" % [m, s], 22, Color.WHITE))
	box.add_child(_res_label("%d shades dispelled   ·   ◆ %d collected" % [RunState.kills, RunState.shards], 16, DIM))
	box.add_child(_res_label(" ", 6, DIM))
	box.add_child(_res_label("+%d SHARDS" % payout, 32, AMBER))
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
