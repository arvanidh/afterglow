class_name SteamCloud
extends Node2D
## STEAM CLOUD — Hybrid: Frost + Flame.
## Deploys a lingering cloud that SLOWS + BURNS enemies inside it.
## No inner classes — uses basic Godot nodes for visuals.

const DISPLAY_NAME := "Steam Cloud"
const ID := "steam_cloud"

const LEVELS := [
	{"interval": 4.0, "damage": 2, "radius": 90.0, "duration": 3.0},
	{"interval": 3.5, "damage": 3, "radius": 100.0, "duration": 3.5},
	{"interval": 3.0, "damage": 4, "radius": 110.0, "duration": 4.0},
	{"interval": 2.5, "damage": 5, "radius": 120.0, "duration": 4.5},
	{"interval": 2.0, "damage": 7, "radius": 140.0, "duration": 5.0},
]

var level := 1
var _cd := 0.0
var arena: Node = null
var rate_scale := 1.0
var _clouds: Array = []


func _stats() -> Dictionary:
	return LEVELS[mini(level - 1, LEVELS.size() - 1)]


func level_up() -> void:
	level = mini(level + 1, 5)


func upgrade_note() -> String:
	return "Lv%d -> %d dmg cloud %.1fs" % [level, _stats()["damage"], _stats()["duration"]]


func _process(delta: float) -> void:
	if arena == null or not is_instance_valid(arena):
		return
	# Tick existing clouds
	var remove: Array = []
	for c in _clouds:
		c["life"] -= delta
		c["tick"] -= delta
		if c["life"] <= 0.0:
			if c["fx"] != null and is_instance_valid(c["fx"]):
				c["fx"].queue_free()
			remove.append(c)
		elif c["tick"] <= 0.0:
			c["tick"] = 0.5
			_damage_cloud(c)
	for c in remove:
		_clouds.erase(c)
	# Spawn new cloud on cooldown
	_cd -= delta * rate_scale
	if _cd > 0.0:
		return
	_cd = _stats()["interval"]
	var player = arena.player
	if player == null or not is_instance_valid(player):
		return
	var stats := _stats()
	var cloud_pos: Vector2 = player.global_position + Vector2.from_angle(randf() * TAU) * 40.0
	_spawn_cloud(cloud_pos, stats)


func _spawn_cloud(at: Vector2, stats: Dictionary) -> void:
	var fx := CPUParticles2D.new()
	fx.position = arena.world.to_local(at)
	fx.one_shot = false
	fx.emitting = true
	fx.amount = 20
	fx.lifetime = stats.get("duration", 3.0) * 0.8
	fx.explosiveness = 0.3
	fx.spread = 180.0
	fx.gravity = Vector2.ZERO
	fx.initial_velocity_min = 10.0
	fx.initial_velocity_max = 30.0
	fx.scale_amount_min = 4.0
	fx.scale_amount_max = 10.0
	fx.color = Color(0.8, 1.0, 0.9, 0.6)
	fx.z_index = 5
	arena.world.add_child(fx)
	_clouds.append({
		"pos": at,
		"fx": fx,
		"life": stats.get("duration", 3.0),
		"tick": 0.0,
		"dmg": stats.get("damage", 2),
		"radius": stats.get("radius", 90.0),
	})


func _damage_cloud(c: Dictionary) -> void:
	if arena.player == null or not is_instance_valid(arena.player):
		return
	var dmg: int = c["dmg"]
	var radius: float = c["radius"]
	var snapshot: Array = arena.enemies.duplicate()
	for e in snapshot:
		if not e.active:
			continue
		if c["pos"].distance_to(e.global_position) < radius:
			if "speed" in e:
				var orig_spd: float = e.speed
				e.speed *= 0.4
				arena.get_tree().create_timer(1.0).timeout.connect(func():
					if is_instance_valid(e):
						e.speed = orig_spd
				)
			if e.take_hit(dmg):
				arena.kill_enemy(e)
			if arena.hud != null and is_instance_valid(arena.hud):
				arena.hud.spawn_float(e.global_position, "SCORCH", Color(1.0, 0.4, 0.0))
