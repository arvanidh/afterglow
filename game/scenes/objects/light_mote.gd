class_name LightMote
extends Node2D
## XP gem dropped by shadows — vacuums toward the player when close (§5.3).
## Collected motes become the run's shard payout on the results screen.

const MAGNET_RANGE := 120.0
const COLLECT_RANGE := 18.0
const PULL_ACCEL := 1500.0
const MAX_PULL_SPEED := 720.0

var arena: Node = null
var active := false
var force_pull := false  # Magnet Storm powerup
var _vel := Vector2.ZERO
var _t := 0.0


func drop(at: Vector2) -> void:
	global_position = at + Vector2(randf_range(-8, 8), randf_range(-8, 8))
	_vel = Vector2.ZERO
	_t = randf() * TAU
	active = true
	show()


func release() -> void:
	active = false
	hide()


func _process(delta: float) -> void:
	if not active or arena == null:
		return
	_t += delta * 4.0
	var player: Node2D = arena.player
	var d := global_position.distance_to(player.global_position)
	if force_pull or d < MAGNET_RANGE:
		_vel = _vel.move_toward((player.global_position - global_position).normalized() * MAX_PULL_SPEED, PULL_ACCEL * delta)
	else:
		_vel = _vel.move_toward(Vector2.ZERO, 800.0 * delta)
	global_position += _vel * delta
	if d < COLLECT_RANGE:
		RunState.add_shards(1)
		release()
	queue_redraw()


func _draw() -> void:
	if not active:
		return
	var pulse := 1.0 + 0.15 * sin(_t)
	var pts := PackedVector2Array([
		Vector2(0, -7) * pulse, Vector2(5, 0) * pulse, Vector2(0, 7) * pulse, Vector2(-5, 0) * pulse,
	])
	draw_circle(Vector2.ZERO, 11.0, Color(1.0, 0.72, 0.0, 0.10))
	draw_colored_polygon(pts, Color(0.6, 0.95, 1.0, 0.9))
	draw_circle(Vector2.ZERO, 2.0, Color.WHITE)
