class_name MiniBoss
extends Node2D
## Mini-boss: appears every 5 levels. Smaller than bosses but tougher than elites.

signal died(miniboss: MiniBoss)

enum Kind { SENTINEL, CRAWLER, ORACLE }

const STATS := {
	Kind.SENTINEL: {
		"name": "SENTINEL", "hp": 40, "speed": 65.0, "radius": 22.0, "damage": 2,
		"body": Color("1a0d2e"), "rim": Color("2a1545"), "eye": Color(0.8, 0.2, 1.0),
		"attack_interval": 1.8, "attack_range": 200.0,
	},
	Kind.CRAWLER: {
		"name": "CRAWLER", "hp": 55, "speed": 80.0, "radius": 26.0, "damage": 2,
		"body": Color("0d1a2e"), "rim": Color("152a45"), "eye": Color(1.0, 0.6, 0.0),
		"attack_interval": 1.2, "attack_range": 150.0,
	},
	Kind.ORACLE: {
		"name": "ORACLE", "hp": 35, "speed": 50.0, "radius": 20.0, "damage": 1,
		"body": Color("0d2e1a"), "rim": Color("15452a"), "eye": Color(0.0, 1.0, 0.6),
		"attack_interval": 2.5, "attack_range": 300.0,
	},
}

var kind := Kind.SENTINEL
var hp := 40
var max_hp := 40
var speed := 65.0
var radius := 22.0
var damage := 2
var active := false
var _player: Node2D
var _flash := 0.0
var _dir := Vector2.RIGHT
var _attack_cd := 2.0
var _orbit_angle := 0.0


func setup(p_kind: Kind, player: Node2D, level_num: int) -> void:
	kind = p_kind
	_player = player
	var s: Dictionary = STATS[kind]
	var hp_mult := 1.0 + float(level_num - 5) * 0.15
	hp = int(ceilf(s["hp"] * hp_mult))
	max_hp = hp
	speed = s["speed"]
	radius = s["radius"]
	damage = s["damage"]
	_attack_cd = s["attack_interval"]
	active = true
	show()


func kind_name() -> String:
	return STATS[kind]["name"]


func take_hit(dmg: int) -> bool:
	hp -= dmg
	_flash = 0.12
	queue_redraw()
	return hp <= 0


func shove(dir: Vector2, force: float) -> void:
	global_position += dir * force * 0.3


func release() -> void:
	active = false
	hide()


func _process(delta: float) -> void:
	if not active or _player == null:
		return
	_flash = maxf(0.0, _flash - delta)
	var to_player := _player.global_position - global_position
	_dir = to_player.normalized()
	var dist := to_player.length()
	# Movement: orbit + approach
	_orbit_angle += delta * 2.0
	var orbit_dir := Vector2(-_dir.y, _dir.x)
	var approach := _dir * speed * 0.4 if dist > 120.0 else Vector2.ZERO
	var orbit := orbit_dir * sin(_orbit_angle) * speed * 0.6
	global_position += (approach + orbit) * delta
	# Attack
	_attack_cd -= delta
	if _attack_cd <= 0.0 and dist < STATS[kind]["attack_range"]:
		_attack_cd = STATS[kind]["attack_interval"]
		# Deal damage to player
		if dist < radius + PlayerSpark.RADIUS + 20.0:
			_player.try_take_damage(damage, global_position)
	queue_redraw()


func _draw() -> void:
	if not active:
		return
	var s: Dictionary = STATS[kind]
	var body: Color = s["body"]
	var rim: Color = s["rim"]
	var eye: Color = s["eye"]
	if _flash > 0.0:
		body = body.lerp(Color.WHITE, _flash / 0.12)
	# Pulsing aura
	var pulse := 0.3 + 0.15 * sin(Time.get_ticks_msec() * 0.005)
	draw_arc(Vector2.ZERO, radius + 8.0, 0.0, TAU, 32, Color(eye.r, eye.g, eye.b, pulse), 2.0)
	draw_arc(Vector2.ZERO, radius + 14.0, 0.0, TAU, 32, Color(eye.r, eye.g, eye.b, pulse * 0.3), 1.0)
	# Body
	draw_circle(Vector2.ZERO, radius + 4.0, Color(rim.r, rim.g, rim.b, 0.3))
	draw_circle(Vector2.ZERO, radius, body)
	# Eyes
	var side := Vector2(-_dir.y, _dir.x)
	var eye_fwd := _dir * radius * 0.35
	for offset in [-1.0, 1.0]:
		var pos: Vector2 = eye_fwd + side * offset * radius * 0.3
		draw_circle(pos, radius * 0.18, Color(eye.r, eye.g, eye.b, 0.5))
		draw_circle(pos, radius * 0.1, eye)
	# Name ring
	draw_arc(Vector2.ZERO, radius + 20.0, 0.0, TAU, 24, Color(eye.r, eye.g, eye.b, 0.15), 1.0)
