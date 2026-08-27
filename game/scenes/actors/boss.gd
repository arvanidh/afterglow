class_name Boss
extends Node2D
## Base boss class — big enemies with multiple attack phases.
## Spawns at levels 10, 20, 30. Camera zooms in on encounter.

signal died(boss: Boss)

enum Kind { WATCHER, DEVOURER, VOID }

const STATS := {
	Kind.WATCHER: {
		"name": "THE WATCHER",
		"hp": 80,
		"speed": 65.0,
		"radius": 40.0,
		"body": Color("1a0a2e"),
		"rim": Color("3d1a6e"),
		"eye": Color(0.4, 0.9, 1.0),
		"damage": 2,
		"phases": 2,
	},
	Kind.DEVOURER: {
		"name": "THE DEVOURER",
		"hp": 150,
		"speed": 50.0,
		"radius": 55.0,
		"body": Color("2e0a0a"),
		"rim": Color("6e1a1a"),
		"eye": Color(1.0, 0.3, 0.1),
		"damage": 3,
		"phases": 3,
	},
	Kind.VOID: {
		"name": "THE VOID",
		"hp": 220,
		"speed": 80.0,
		"radius": 45.0,
		"body": Color("0a0a1a"),
		"rim": Color("1a1a3d"),
		"eye": Color(0.8, 0.0, 1.0),
		"damage": 3,
		"phases": 3,
	},
}

var kind := Kind.WATCHER
var hp := 80
var max_hp := 80
var speed := 65.0
var radius := 40.0
var damage := 2
var active := false
var phase := 1
var max_phases := 2

var _player: Node2D
var _flash := 0.0
var _dir := Vector2.RIGHT
var _attack_cd := 2.0
var _phase2_triggered := false
var _phase3_triggered := false
var _teleport_cd := 4.0
var _summon_cd := 6.0
var _charge_speed := 0.0
var _charge_dir := Vector2.ZERO
var _is_charging := false
var _charge_time := 0.0
var _invulnerable := false
var _invuln_timer := 0.0


func setup(p_kind: Kind, player: Node2D) -> void:
	kind = p_kind
	_player = player
	var s: Dictionary = STATS[kind]
	hp = int(s["hp"])
	max_hp = hp
	speed = float(s["speed"])
	radius = float(s["radius"])
	damage = int(s["damage"])
	max_phases = int(s["phases"])
	phase = 1
	_attack_cd = 2.0
	_phase2_triggered = false
	_phase3_triggered = false
	_teleport_cd = 4.0
	_summon_cd = 6.0
	_is_charging = false
	_invulnerable = false
	_invuln_timer = 0.0
	active = true
	show()
	z_index = 15


func take_hit(dmg: int) -> bool:
	if _invulnerable:
		return false
	hp -= dmg
	_flash = 0.12
	queue_redraw()
	# Phase transitions
	if hp <= max_hp * 0.66 and not _phase2_triggered:
		_phase2_triggered = true
		phase = 2
		_invulnerable = true
		_invuln_timer = 1.5  # Brief invuln during phase transition
		# Phase transition shockwave
		_spawn_shockwave(120.0)
	if hp <= max_hp * 0.33 and not _phase3_triggered:
		_phase3_triggered = true
		phase = 3
		_invulnerable = true
		_invuln_timer = 1.5
		_spawn_shockwave(180.0)
	return hp <= 0


func _process(delta: float) -> void:
	if not active or _player == null:
		return
	_flash = maxf(0.0, _flash - delta)
	_invuln_timer = maxf(0.0, _invuln_timer - delta)
	if _invuln_timer <= 0.0:
		_invulnerable = false
	var to_player := _player.global_position - global_position
	_dir = to_player.normalized()
	var dist := to_player.length()
	# Boss-specific behavior
	match kind:
		Kind.WATCHER:
			_process_watcher(delta, dist)
		Kind.DEVOURER:
			_process_devourer(delta, dist)
		Kind.VOID:
			_process_void(delta, dist)
	queue_redraw()


func _process_watcher(delta: float, dist: float) -> void:
	# Watcher: circles player, fires projectiles, teleports in phase 2
	if _is_charging:
		global_position += _charge_dir * _charge_speed * delta
		_charge_time -= delta
		if _charge_time <= 0.0:
			_is_charging = false
		return
	# Circle the player
	_dir = to_player_global().normalized()
	var side := Vector2(-_dir.y, _dir.x)
	global_position += side * speed * 0.6 * delta
	# Keep distance
	if dist < 200.0:
		global_position -= _dir * speed * 0.5 * delta
	elif dist > 350.0:
		global_position += _dir * speed * 0.5 * delta
	# Attacks
	_attack_cd -= delta
	if _attack_cd <= 0.0:
		if phase >= 2 and dist < 300.0:
			# Phase 2: charge attack
			_is_charging = true
			_charge_dir = _dir
			_charge_speed = speed * 3.5
			_charge_time = 0.4
			_attack_cd = 3.0
		else:
			# Fire projectile (handled by arena)
			_attack_cd = randf_range(1.5, 2.5)
			# Arena will detect this and fire a spit_orb


func _process_devourer(delta: float, dist: float) -> void:
	# Devourer: slow, tanky, area attacks, charges in phase 3
	if _is_charging:
		global_position += _charge_dir * _charge_speed * delta
		_charge_time -= delta
		if _charge_time <= 0.0:
			_is_charging = false
		return
	# Slow chase
	global_position += _dir * speed * delta
	# Attacks
	_attack_cd -= delta
	if _attack_cd <= 0.0:
		if phase >= 3 and dist < 400.0:
			# Phase 3: charge
			_is_charging = true
			_charge_dir = _dir
			_charge_speed = speed * 4.0
			_charge_time = 0.6
			_attack_cd = 4.0
		elif phase >= 2:
			# Phase 2: area slam (handled by arena)
			_attack_cd = 2.5
		else:
			_attack_cd = 2.0


func _process_void(delta: float, dist: float) -> void:
	# Void: fast, teleports, summons minions
	_teleport_cd -= delta
	if _teleport_cd <= 0.0:
		# Teleport near player
		var angle := randf() * TAU
		var offset := Vector2.from_angle(angle) * randf_range(100.0, 200.0)
		global_position = _player.global_position + offset
		_teleport_cd = randf_range(2.0, 4.0) if phase == 1 else randf_range(1.0, 2.5)
		_flash = 0.3
	# Chase between teleports
	global_position += _dir * speed * delta
	# Attacks
	_attack_cd -= delta
	if _attack_cd <= 0.0:
		if phase >= 3:
			# Phase 3: summon minions (handled by arena)
			_attack_cd = 5.0
		elif phase >= 2:
			# Phase 2: fire multiple projectiles
			_attack_cd = 1.5
		else:
			_attack_cd = 1.8


func to_player_global() -> Vector2:
	if _player:
		return _player.global_position - global_position
	return Vector2.RIGHT


func _spawn_shockwave(radius: float) -> void:
	# Visual shockwave — arena will handle damage
	pass


func release() -> void:
	active = false
	hide()


func _draw() -> void:
	if not active:
		return
	var s: Dictionary = STATS[kind]
	var body: Color = s["body"]
	var rim: Color = s["rim"]
	var eye: Color = s["eye"]
	if _flash > 0.0:
		body = body.lerp(Color.WHITE, _flash / 0.12)
	# Invulnerability shimmer
	if _invulnerable:
		var shimmer := 0.3 + 0.2 * sin(Time.get_ticks_msec() * 0.01)
		body.a = 0.5 + shimmer * 0.3
	# Phase indicator — pulsing aura gets more intense in later phases
	var pulse_intensity := 0.2 + phase * 0.15
	var pulse := pulse_intensity + 0.1 * sin(Time.get_ticks_msec() * 0.005)
	# Outer aura
	draw_arc(Vector2.ZERO, radius + 20.0, 0.0, TAU, 50, Color(eye.r, eye.g, eye.b, pulse * 0.3), 3.0)
	draw_arc(Vector2.ZERO, radius + 12.0, 0.0, TAU, 50, Color(eye.r, eye.g, eye.b, pulse * 0.5), 2.0)
	# Body
	draw_circle(Vector2.ZERO, radius + 8.0, Color(rim.r, rim.g, rim.b, 0.25))
	draw_circle(Vector2.ZERO, radius, body)
	# Charging indicator
	if _is_charging:
		draw_arc(Vector2.ZERO, radius + 6.0, 0.0, TAU, 30, Color(1.0, 0.3, 0.1, 0.8), 4.0)
	# Eyes
	match kind:
		Kind.WATCHER:
			# Single large eye
			draw_circle(Vector2.ZERO, radius * 0.35, Color(eye.r, eye.g, eye.b, 0.6))
			draw_circle(Vector2.ZERO, radius * 0.2, eye)
			# Pupil follows player
			draw_circle(_dir * radius * 0.12, radius * 0.1, Color(0.05, 0.05, 0.15))
		Kind.DEVOURER:
			# Two glowing eyes
			var side := Vector2(-_dir.y, _dir.x)
			for offset in [-1.0, 1.0]:
				var pos: Vector2 = _dir * radius * 0.3 + side * offset * radius * 0.25
				draw_circle(pos, radius * 0.18, Color(eye.r, eye.g, eye.b, 0.5))
				draw_circle(pos, radius * 0.1, eye)
		Kind.VOID:
			# Three eyes in triangle
			for i in range(3):
				var angle := _dir.angle() + (float(i) - 1.0) * 0.8
				var pos := Vector2.from_angle(angle) * radius * 0.3
				draw_circle(pos, radius * 0.14, Color(eye.r, eye.g, eye.b, 0.6))
				draw_circle(pos, radius * 0.07, eye)
	# Health bar (drawn above boss)
	if hp < max_hp:
		var bar_w := radius * 2.2
		var bar_h := 6.0
		var bar_y := -radius - 25.0
		draw_rect(Rect2(-bar_w / 2, bar_y, bar_w, bar_h), Color(0.1, 0.1, 0.1, 0.8))
		var fill := float(hp) / float(max_hp)
		var hp_color := Color(0.3, 1.0, 0.3) if fill > 0.5 else Color(1.0, 0.8, 0.2) if fill > 0.25 else Color(1.0, 0.2, 0.1)
		draw_rect(Rect2(-bar_w / 2, bar_y, bar_w * fill, bar_h), hp_color)
		# Border
		draw_rect(Rect2(-bar_w / 2, bar_y, bar_w, bar_h), Color.WHITE, false, 1.0)
