class_name DamageableObject extends StaticBody3D

signal health_changed(current_health, max_health)
signal died

@export var max_health: float = 100.0
var current_health: float
var is_dying: bool = false

func _ready() -> void:
	current_health = max_health
	collision_layer = 1
	collision_mask = 1

func take_damage(amount: float, source: Node = null) -> void:
	current_health -= amount
	emit_signal("health_changed", current_health, max_health)
	
	if current_health <= 0:
		die(source)

func die(source: Node = null) -> void:
	emit_signal("died")
	get_parent().queue_free()

func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)
	emit_signal("health_changed", current_health, max_health)
