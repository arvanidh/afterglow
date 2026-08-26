class_name PlayerSpark
extends Node2D
## THE SPARK — bright player, shadow enemies (§7.1 law). Owns movement, the
## dash skill, and every run-scoped modifier granted by draft cards.

signal took_damage(current_hp: int)
signal dashed

const SPEED := 295.0
const IFRAMES := 0.8
const RADIUS := 13.0

const DASH_SPEED := 980.0
const DASH_TIME := 0.16
const DASH_IFRAMES := 0.32
const DASH_BASE_CD := 2.3

var move_dir := Vector2.ZERO
var mods := {
	"speed_mult": 1.0, "dmg_mult": 1.0, "rate_mult": 1.0, "magnet_mult": 1.0,
	"dash_cd_mult": 1.0, "shard_mult": 1.0, "bonus_hp": 0, "fork_chance": 0.0,
}
var dashing := false
var dash_cd := 0.0
var facing := Vector2.RIGHT
var _iframes := 0.0
var _knockback := Vector2.ZERO
var _dash_left := 0.0
var _dash_dir := Vector2.RIGHT
var _trail: CPUParticles2D


func _ready() -> void:
	z_index = 20
	_trail = CPUParticles2D.new()
	_trail.amount = 32
	_trail.lifetime = 0.45
	_trail.local_coords = false
	_trail.gravity = Vector2.ZERO
	_trail.initial_velocity_min = 6.0
	_trail.initial_velocity_max = 22.0
	_trail.scale_amount_min = 1.8
	_trail.scale_amount_max = 5.0
	_trail.damping_min = 80.0
	_trail.damping_max = 160.0
	_trail.color = Color(0.0, 0.94, 1.0, 0.6)
	add_child(_trail)


func effective_max_hp() -> int:
	return RunState.max_hp + int(mods["bonus_hp"])


func heal(n: int) -> void:
	RunState.hp = mini(RunState.hp + n, effective_max_hp())


func apply_passive(id: String) -> void:
	match id:
		"swift":
			mods["speed_mult"] = float(mods["speed_mult"]) + 0.10
		"overclock":
			mods["rate_mult"] = float(mods["rate_mult"]) + 0.14
		"focus":
			mods["dmg_mult"] = float(mods["dmg_mult"]) + 0.20
		"magnet":
			mods["magnet_mult"] = float(mods["magnet_mult"]) + 0.45
		"ghost":
			mods["dash_cd_mult"] = float(mods["dash_cd_mult"]) * 0.78
		"sigil":
			mods["shard_mult"] = float(mods["shard_mult"]) + 0.15
		"twin":
			mods["fork_chance"] = float(mods["fork_chance"]) + 0.08
		"vitality":
			mods["bonus_hp"] = int(mods["bonus_hp"]) + 1
			heal(1)


func try_dash(dir: Vector2) -> bool:
	if dashing or dash_cd > 0.0:
		return false
	dashing = true
	_dash_left = DASH_TIME
	_iframes = maxf(_iframes, DASH_IFRAMES)
	_dash_dir = dir.normalized() if dir.length_squared() > 0.001 else facing
	Audio.play("dash", -2.0)
	Input.vibrate_handheld(20)
	dashed.emit()
	queue_redraw()
	return true


func _process(delta: float) -> void:
	_iframes = maxf(0.0, _iframes - delta)
	dash_cd = maxf(0.0, dash_cd - delta)
	if dashing:
		position += _dash_dir * DASH_SPEED * delta
		_dash_left -= delta
		if _dash_left <= 0.0:
			dashing = false
			dash_cd = DASH_BASE_CD * float(mods["dash_cd_mult"])
	else:
		if move_dir.length_squared() > 0.001:
			facing = move_dir.normalized()
		var vel := move_dir * SPEED * float(mods["speed_mult"]) + _knockback
		position += vel * delta
	_knockback = _knockback.move_toward(Vector2.ZERO, 900.0 * delta)
	_trail.emitting = move_dir.length_squared() > 0.01 or dashing
	queue_redraw()


func try_take_damage(amount: int, from_pos: Vector2) -> bool:
	if _iframes > 0.0 or dashing:
		return false
	RunState.hp = maxi(0, RunState.hp - amount)
	RunState.hp = mini(RunState.hp, effective_max_hp())
	_iframes = IFRAMES
	_knockback = (global_position - from_pos).normalized() * 240.0
	took_damage.emit(RunState.hp)
	Input.vibrate_handheld(35)
	return true


func _draw() -> void:
	var flicker := 1.0 if _iframes <= 0.0 else 0.35 + 0.65 * absf(sin(Time.get_ticks_msec() * 0.02))
	if dashing:
		draw_line(-_dash_dir * 30.0, _dash_dir * 10.0, Color(0.0, 0.94, 1.0, 0.45), 8.0)
		var xf := Transform2D(_dash_dir.angle(), Vector2.ZERO).scaled(Vector2(2.1, 0.6))
		draw_set_transform_matrix(xf)
		_draw_body(flicker)
		draw_set_transform_matrix(Transform2D())
		return
	_draw_body(flicker)


func _draw_body(flicker: float) -> void:
	draw_circle(Vector2.ZERO, RADIUS * 2.6, Color(0.0, 0.94, 1.0, 0.07 * flicker))
	draw_circle(Vector2.ZERO, RADIUS * 1.6, Color(0.0, 0.94, 1.0, 0.16 * flicker))
	draw_circle(Vector2.ZERO, RADIUS, Color(0.75, 1.0, 1.0, 0.95 * flicker))
	draw_circle(Vector2.ZERO, RADIUS * 0.45, Color.WHITE)
	draw_circle(facing * RADIUS * 0.8, 2.6, Color(1.0, 0.72, 0.0, 0.9 * flicker))
