class_name PlayerSpark
extends Node2D
## THE SPARK — the last light of the city (GDD §7.1 style law: bright player,
## shadow enemies). Movement comes from the arena's floating joystick (§6).

signal took_damage(current_hp: int)

const SPEED := 295.0
const IFRAMES := 0.8
const RADIUS := 13.0

var move_dir := Vector2.ZERO
var _iframes := 0.0
var _knockback := Vector2.ZERO
var _trail: CPUParticles2D


func _ready() -> void:
	z_index = 20
	_trail = CPUParticles2D.new()
	_trail.amount = 26
	_trail.lifetime = 0.5
	_trail.local_coords = false
	_trail.gravity = Vector2.ZERO
	_trail.initial_velocity_min = 4.0
	_trail.initial_velocity_max = 14.0
	_trail.scale_amount_min = 1.5
	_trail.scale_amount_max = 4.0
	_trail.color = Color(0.0, 0.94, 1.0, 0.55)
	add_child(_trail)


func _process(delta: float) -> void:
	_iframes = maxf(0.0, _iframes - delta)
	var vel := move_dir * SPEED + _knockback
	position += vel * delta
	_knockback = _knockback.move_toward(Vector2.ZERO, 900.0 * delta)
	_trail.emitting = move_dir.length_squared() > 0.01
	queue_redraw()


func try_take_damage(amount: int, from_pos: Vector2) -> bool:
	if _iframes > 0.0:
		return false
	RunState.hp = maxi(0, RunState.hp - amount)
	_iframes = IFRAMES
	_knockback = (global_position - from_pos).normalized() * 240.0
	took_damage.emit(RunState.hp)
	Input.vibrate_handheld(35)
	return true


func _draw() -> void:
	var flicker := 1.0 if _iframes <= 0.0 else 0.35 + 0.65 * absf(sin(Time.get_ticks_msec() * 0.02))
	draw_circle(Vector2.ZERO, RADIUS * 2.6, Color(0.0, 0.94, 1.0, 0.07 * flicker))
	draw_circle(Vector2.ZERO, RADIUS * 1.6, Color(0.0, 0.94, 1.0, 0.16 * flicker))
	draw_circle(Vector2.ZERO, RADIUS, Color(0.75, 1.0, 1.0, 0.95 * flicker))
	draw_circle(Vector2.ZERO, RADIUS * 0.45, Color.WHITE)
