extends Node2D
## MENU state — title, pulsing CTA, cosmetic sparks. Any touch descends into
## a run on the Promenade. The old FPS label now shows your record (§8.2).

@onready var title: Label = $UI/CenterBox/VBox/Title
@onready var hint: Label = $UI/CenterBox/VBox/Hint
@onready var best_label: Label = $UI/FPS
@onready var version_label: Label = $UI/Version


func _ready() -> void:
	GameState.change_state(GameState.State.MENU)
	version_label.text = "v0.0.3 · levels + guns"
	var save := SaveSystem.load_save()
	var runs := int(save.get("runs", 0))
	if runs > 0:
		var best := int(save.get("best_time", 0.0))
		best_label.text = "best %d:%02d  ·  %d runs" % [best / 60, best % 60, runs]
	else:
		best_label.text = ""
	_pulse(title, 1.2)
	_pulse(hint, 0.75)


func _pulse(item: CanvasItem, period: float) -> void:
	var tw := create_tween().set_loops()
	tw.tween_property(item, "modulate:a", 0.4, period).set_trans(Tween.TRANS_SINE)
	tw.tween_property(item, "modulate:a", 1.0, period).set_trans(Tween.TRANS_SINE)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_spawn_spark(event.position)
		_start_run()


func _start_run() -> void:
	RunState.reset_run()
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
