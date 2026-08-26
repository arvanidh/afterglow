extends Node2D
## MENU state - title, pulsing CTA, cosmetic sparks, GEM SHOP overlay.

@onready var title: Label = $UI/CenterBox/VBox/Title
@onready var hint: Label = $UI/CenterBox/VBox/Hint
@onready var best_label: Label = $UI/FPS
@onready var version_label: Label = $UI/Version

var _shop_root: Control = null


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
	_pulse(title, 1.2)
	_pulse(hint, 0.75)
	var controls := Label.new()
	controls.text = "left thumb to move  |  tap diamond to dash"
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_theme_font_size_override("font_size", 14)
	controls.add_theme_color_override("font_color", Color(1, 1, 1, 0.35))
	$UI/CenterBox/VBox.add_child(controls)
	var shop_btn := Button.new()
	shop_btn.text = "SHOP"
	shop_btn.custom_minimum_size = Vector2(200, 50)
	shop_btn.add_theme_font_size_override("font_size", 22)
	shop_btn.pressed.connect(_open_shop)
	$UI/CenterBox/VBox.add_child(shop_btn)


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


func _open_shop() -> void:
	if _shop_root != null:
		return
	var save := SaveSystem.load_save()
	var gems: int = int(save.get("gems", 0))
	var upgrades: Dictionary = save.get("upgrades", {})
	var vsz := get_viewport_rect().size

	# Full-screen overlay
	_shop_root = Control.new()
	_shop_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_shop_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_shop_root)

	# Dim background - closes shop on tap OUTSIDE the panel
	var dim := ColorRect.new()
	dim.color = Color(0.01, 0.01, 0.03, 0.88)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_shop_root.add_child(dim)

	# Scroll container for the full-screen content
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 20
	scroll.offset_right = -20
	scroll.offset_top = 30
	scroll.offset_bottom = -30
	scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shop_root.add_child(scroll)

	# Content VBox inside scroll
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 16)
	scroll.add_child(content)

	# Title
	var title2 := Label.new()
	title2.text = "UPGRADE SHOP"
	title2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title2.add_theme_font_size_override("font_size", 32)
	title2.add_theme_color_override("font_color", Color(1.0, 0.72, 0.0))
	content.add_child(title2)

	# Gem balance
	var bal := Label.new()
	bal.name = "Balance"
	bal.text = "%d gems available" % gems
	bal.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bal.add_theme_font_size_override("font_size", 22)
	bal.add_theme_color_override("font_color", Color(1.0, 0.72, 0.0))
	content.add_child(bal)

	# Upgrade cards - full width, 1 per row for easy tapping
	for id: String in SaveSystem.UPGRADES:
		var def: Dictionary = SaveSystem.UPGRADES[id]
		var cur_lv: int = int(upgrades.get(id, 0))
		var max_lv: int = int(def["max"])
		var costs: Array = def["costs"]
		var at_max := cur_lv >= max_lv
		var cost: int = costs[cur_lv] if cur_lv < costs.size() else 0
		var can_buy := gems >= cost and not at_max
		var card := _make_upgrade_card(id, def["title"], def["desc"], cur_lv, max_lv, cost, can_buy, bal)
		content.add_child(card)

	# Close button
	var close_btn := Button.new()
	close_btn.text = "BACK"
	close_btn.custom_minimum_size = Vector2(0, 55)
	close_btn.add_theme_font_size_override("font_size", 22)
	close_btn.pressed.connect(_close_shop)
	content.add_child(close_btn)

	# Close on dim tap (after children are added, so buttons get priority)
	dim.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventScreenTouch and ev.pressed:
			_close_shop())


func _make_upgrade_card(id: String, title: String, desc: String, cur_lv: int, max_lv: int, cost: int, can_buy: bool, bal_label: Label) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 90)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var csb := StyleBoxFlat.new()
	csb.bg_color = Color(0.06, 0.07, 0.14, 0.95)
	csb.border_color = Color(0.0, 0.94, 1.0, 0.5) if can_buy else Color(1, 1, 1, 0.12)
	csb.set_border_width_all(2)
	csb.set_corner_radius_all(12)
	csb.content_margin_left = 18
	csb.content_margin_right = 18
	csb.content_margin_top = 14
	csb.content_margin_bottom = 14
	card.add_theme_stylebox_override("panel", csb)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(hbox)

	# Left side: title + description
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 2)
	hbox.add_child(left)

	var t := Label.new()
	t.text = "%s  Lv%d/%d" % [title, cur_lv, max_lv]
	t.add_theme_font_size_override("font_size", 20)
	t.add_theme_color_override("font_color", Color.WHITE)
	left.add_child(t)

	var d := Label.new()
	d.text = desc
	d.add_theme_font_size_override("font_size", 15)
	d.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	left.add_child(d)

	# Right side: buy button or MAXED
	if cur_lv >= max_lv:
		var max_label := Label.new()
		max_label.text = "MAXED"
		max_label.add_theme_font_size_override("font_size", 18)
		max_label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.55))
		max_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hbox.add_child(max_label)
	else:
		var buy_btn := Button.new()
		buy_btn.text = "BUY\n%d gems" % cost
		buy_btn.custom_minimum_size = Vector2(100, 50)
		buy_btn.add_theme_font_size_override("font_size", 16)
		buy_btn.disabled = not can_buy
		buy_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		buy_btn.pressed.connect(_buy_upgrade.bind(id, cost, bal_label))
		hbox.add_child(buy_btn)

	return card


func _buy_upgrade(id: String, cost: int, bal_label: Label) -> void:
	if SaveSystem.buy_upgrade(id):
		Audio.play("powerup", -2.0)
		_close_shop()
		_open_shop()


func _close_shop() -> void:
	if _shop_root != null:
		_shop_root.queue_free()
		_shop_root = null


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
