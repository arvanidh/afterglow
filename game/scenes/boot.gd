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
	close.pressed.connect(_close_shop)
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
