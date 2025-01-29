extends Area3D

@export var damage := 1
@export var is_headshot := false

signal body_part_hit(damage: int, is_headshot: bool)

func hit():
	emit_signal("body_part_hit", damage, is_headshot)
