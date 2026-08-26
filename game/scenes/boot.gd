extends Node2D
## First-light scene: proves rendering, touch input, autoloads, and the
## analytics pipeline in one screen. Replaced by the real menu in P0.

const BUILD_LABEL := "v0.0.1 · first light"

@onready var title: Label = $UI/CenterBox/VBox/Title
@onready var version_label: Label = $UI/Version
@onready var fps_label: Label = $UI/FPS


func _ready() -> void:
	version_label.text = BUILD_LABEL
	Analytics.design_event("boot", {"scene": "first_light"})
	var tw := create_tween().set_loops()
	tw.tween_property(title, "modulate:a", 0.55, 1.2).set_trans(Tween.TRANS_SINE)
	tw.tween_property(title, "modulate:a", 1.0, 1.2).set_trans(Tween.TRANS_SINE)


func _process(_delta: float) -> void:
	fps_label.text = "%d fps" % Engine.get_frames_per_second()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_spawn_spark(event.position)
		RunState.shards += 1


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
