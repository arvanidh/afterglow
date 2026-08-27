class_name PlasmaStorm
extends Node2D
## PLASMA STORM — evolved from Pulse + Orbit.
## Fires homing orbs that explode on contact, dealing area damage.

const RANGE := 500.0
const DISPLAY_NAME := "Plasma Storm"
const ID := "plasma_storm"
const EVOLVED := true

const LEVELS := [
	{"interval": 0.40, "damage": 3, "explode_radius": 70.0},
	{"interval": 0.36, "damage": 4, "explode_radius": 80.0},
	{"interval": 0.32, "damage": 5, "explode_radius": 90.0},
	{"interval": 0.28, "damage": 6, "explode_radius": 100.0},
	{"interval": 0.24, "damage": 8, "explode_radius": 120.0},
]

var level := 1
var _cd := 0.4
var arena: Node = null
var rate_scale := 1.0


func _stats() -> Dictionary:
	return LEVELS[mini(level - 1, LEVELS.size() - 1)]


func level_up() -> void:
	level = mini(level + 1, 5)


func upgrade_note() -> String:
	return "EVOLVED Lv%d → %d dmg · r%d" % [level, _stats()["damage"], int(_stats()["explode_radius"])]


func _player_mods() -> Dictionary:
	return (get_parent() as PlayerSpark).mods if get_parent() is PlayerSpark else {}


func _process(delta: float) -> void:
	if arena == null or not is_instance_valid(arena):
		return
	var mods := _player_mods()
	var rate_total: float = rate_scale * float(mods.get("rate_mult", 1.0))
	_cd -= delta * rate_total
	if _cd > 0.0:
		return
	_cd = float(_stats()["interval"])
	var target: ShadowEnemy = arena.nearest_enemy(global_position, RANGE)
	if target == null:
		return
	# Fire homing orb
	var dmg := int(ceilf(float(_stats()["damage"]) * float(mods.get("dmg_mult", 1.0))))
	_fire_orb(target, dmg)


func _fire_orb(target: ShadowEnemy, dmg: int) -> void:
	var dir := global_position.direction_to(target.global_position)
	var origin := global_position + (dir * PlayerSpark.RADIUS)
	# Create homing orb
	var orb := HomingOrb.new()
	orb.setup(origin, target, dmg, float(_stats()["explode_radius"]))
	arena.world.add_child(orb)
	Audio.play("shoot", -5.0)


class HomingOrb extends Node2D:
	var _target: ShadowEnemy
	var _velocity := Vector2.ZERO
	var _damage := 3
	var _explode_radius := 70.0
	var _speed := 350.0
	var _life := 2.0
	var _active := true

	func setup(from: Vector2, target: ShadowEnemy, dmg: int, radius: float) -> void:
		global_position = from
		_target = target
		_damage = dmg
		_explode_radius = radius
		_active = true
		look_at(target.global_position)

	func _process(delta: float) -> void:
		if not _active:
			return
		_life -= delta
		if _life <= 0.0:
			_explode()
			return
		# Homing toward target
		if is_instance_valid(_target) and _target.active:
			var dir := global_position.direction_to(_target.global_position)
			_velocity = _velocity.lerp(dir * _speed, 5.0 * delta)
		global_position += _velocity * delta
		# Check collision with any enemy
		var arena = get_parent().get_parent().get_parent() if get_parent() and get_parent().get_parent() else null
		if arena and arena is Node2D:
			for e in arena.enemies:
				if not e.active:
					continue
				if global_position.distance_to(e.global_position) < 15.0:
					_explode()
					return
		queue_redraw()

	func _explode() -> void:
		_active = false
		# Find arena from scene tree
		var arena = null
		var node = get_parent()
		while node:
			if node.has_method("kill_enemy"):
				arena = node
				break
			node = node.get_parent()
		if arena:
			# Damage all enemies in radius
			for e in arena.enemies:
				if not e.active:
					continue
				if global_position.distance_to(e.global_position) < _explode_radius:
					if e.take_hit(_damage):
						arena.kill_enemy(e)
			# Visual explosion
			arena.spawn_ring(global_position, _explode_radius, Color(0.0, 0.94, 1.0, 0.8))
			arena._burst(global_position, Color(0.0, 0.94, 1.0))
		queue_free()

	func _draw() -> void:
		if not _active:
			return
		draw_circle(Vector2.ZERO, 6.0, Color(0.0, 0.94, 1.0, 0.3))
		draw_circle(Vector2.ZERO, 3.0, Color(0.75, 1.0, 1.0, 0.9))
