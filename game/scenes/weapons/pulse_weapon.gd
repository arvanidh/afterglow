class_name PulseWeapon
extends Node2D
## PULSE BOLT — fires at the nearest enemy (§5.4). Level-1 tuning; evolutions,
## levels, and additional weapons arrive as .tres data tables.

const FIRE_INTERVAL := 0.45
const RANGE := 440.0

var _cd := 0.0
var arena: Node = null  # set by the arena; provides nearest_enemy() / acquire_bolt()


func _process(delta: float) -> void:
	if arena == null:
		return
	_cd -= delta
	if _cd > 0.0:
		return
	var target: ShadowEnemy = arena.nearest_enemy(global_position, RANGE)
	if target == null:
		return
	_cd = FIRE_INTERVAL
	var dir := (target.global_position - global_position).normalized()
	arena.acquire_bolt().launch(global_position + dir * PlayerSpark.RADIUS, dir)
