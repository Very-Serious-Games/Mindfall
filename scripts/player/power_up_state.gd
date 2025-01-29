extends Node

var active_powerups: Dictionary = {}

func store_powerups(powerups: Dictionary) -> void:
	active_powerups = powerups.duplicate()

func get_powerups() -> Dictionary:
	return active_powerups

func clear_powerups() -> void:
	active_powerups.clear()
