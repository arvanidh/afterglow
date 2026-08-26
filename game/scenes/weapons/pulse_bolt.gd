class_name PulseBolt
extends Node2D
## A single cyan bolt. Pool-managed by the arena (§12.3 pooling rule).

const SPEED := 560.0

var velocity := Vector2.ZERO
var life := 1.15
var damage := 1
var active := false


func launch(from: Vector2, dir: Vector2, dmg := 1) -> void:
	global_position = from
	velocity = dir * SPEED
	damage = dmg
	life = 1.15
	active = true
	show()
	queue_redraw()


func deactivate() -> void:
	active = false
	hide()


func _process(delta: float) -> void:
	if not active:
		return
	global_position += velocity * delta
	life -= delta
	if life <= 0.0:
		deactivate()
	queue_redraw()


func _draw() -> void:
	if not active:
		return
	var tip := velocity.normalized() * 9.0
	draw_line(-tip, tip, Color(0.0, 0.94, 1.0, 0.35), 6.0)
	draw_line(-tip * 0.7, tip * 0.85, Color(0.75, 1.0, 1.0), 2.5)
	draw_circle(tip, 2.5, Color.WHITE)
