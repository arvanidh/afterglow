class_name SteamCloud
extends Node2D
## STEAM CLOUD — Hybrid: Frost + Flame.
## Deploys a lingering cloud that SLOWS + BURNS enemies inside it.

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

var _active_clouds: Array = []


func _stats() -> Dictionary:
	return LEVELS[mini(level - 1, LEVELS.size() - 1)]


func level_up() -> void:
	level = mini(level + 1, 5)


func upgrade_note() -> String:
	return "Lv%d → %d dmg · cloud %.1fs" % [level, _stats()["damage"], _stats()["duration"]]


func _process(delta: float) -> void:
	if arena == null or not is_instance_valid(arena):
		return
	_cd -= delta * rate_scale
	if _cd > 0.0:
		return
	# Deploy cloud near player
	var stats := _stats()
	_cd = stats["interval"]
	_deploy_cloud(stats)


func _deploy_cloud(stats: Dictionary) -> void:
	var player = arena.player
	if player == null or not is_instance_valid(player):
		return
	# Cloud at player position with slight offset
	var cloud_pos: Vector2 = player.global_position + Vector2.from_angle(randf() * TAU) * 40.0
	var cloud := _CloudNode.new()
	cloud.stats = stats
	cloud.arena = arena
	cloud.position = arena.world.to_local(cloud_pos)
	arena.world.add_child(cloud)
	_active_clouds.append(cloud)


class _CloudNode extends Node2D:
	var stats := {}
	var arena: Node = null
	var _tick := 0.0
	var _life := 0.0
	var _radius := 90.0


	func _ready() -> void:
		_radius = stats.get("radius", 90.0)
		_life = stats.get("duration", 3.0)
		_tick = 0.0
		z_index = 5


	func _process(delta: float) -> void:
		_life -= delta
		if _life <= 0.0:
			queue_free()
			return
		_tick -= delta
		if _tick <= 0.0:
			_tick = 0.5  # Damage tick every 0.5s
			_damage_tick()
		queue_redraw()


	func _damage_tick() -> void:
		if arena == null or not is_instance_valid(arena) or arena.player == null:
			return
		var player = arena.player
		var dmg: int = stats.get("damage", 2)
		# Damage + slow all enemies in radius
		var snapshot: Array = arena.enemies.duplicate()
		for e in snapshot:
			if not e.active:
				continue
			if global_position.distance_to(e.global_position) < _radius:
				# Slow effect
				if e.has_method("get") and "speed" in e:
					var orig_speed: float = e.speed
					e.speed *= 0.4
					# Restore after 1s
					if arena.get_tree():
						arena.get_tree().create_timer(1.0).timeout.connect(func():
							if is_instance_valid(e):
								e.speed = orig_speed
						)
				# Burn damage
				if e.take_hit(dmg):
					arena.kill_enemy(e)
				if arena.hud != null and is_instance_valid(arena.hud):
					arena.hud.spawn_float(e.global_position, "SCORCH", Color(1.0, 0.4, 0.0))


	func _draw() -> void:
		# Steam cloud visual: pulsing white-green circle
		var alpha: float = clampf(_life / 1.0, 0.0, 0.25) * (0.8 + sin(Time.get_ticks_msec() * 0.005) * 0.2)
		draw_circle(Vector2.ZERO, _radius, Color(0.8, 1.0, 0.9, alpha * 0.3))
		draw_circle(Vector2.ZERO, _radius * 0.6, Color(0.9, 1.0, 0.95, alpha * 0.5))
		draw_circle(Vector2.ZERO, _radius * 0.3, Color(1.0, 1.0, 1.0, alpha * 0.6))
		# Warning ring
		draw_arc(Vector2.ZERO, _radius, 0.0, TAU, 32, Color(0.8, 1.0, 0.9, alpha * 0.8), 2.0)
