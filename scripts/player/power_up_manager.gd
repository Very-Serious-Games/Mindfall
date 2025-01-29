class_name PowerUpManager extends Node

var active_powerups: Dictionary = {}
var dash_charges: int = 1
var max_jumps: int = 1
var current_jumps: int = 0
var reload_speed_multiplier: float = 1.0
var burst_shot_count: int = 1

func _ready() -> void:
	# Load stored powerups on initialization
	active_powerups = PowerUpState.get_powerups()
	_apply_stored_powerups()

func _apply_stored_powerups() -> void:
	for powerup in active_powerups:
		match powerup:
			PowerUp.PowerUpType.BURST_SHOT:
				burst_shot_count = 2
			PowerUp.PowerUpType.FAST_RELOAD:
				reload_speed_multiplier = 0.5
			PowerUp.PowerUpType.DOUBLE_JUMP:
				max_jumps = 2
			PowerUp.PowerUpType.DOUBLE_DASH:
				dash_charges = 2

func activate_powerup(type: PowerUp.PowerUpType) -> void:
	if type in active_powerups:
		return
		
	active_powerups[type] = true
	match type:
		PowerUp.PowerUpType.BURST_SHOT:
			burst_shot_count = 2
		PowerUp.PowerUpType.FAST_RELOAD:
			reload_speed_multiplier = 0.5
		PowerUp.PowerUpType.DOUBLE_JUMP:
			max_jumps = 2
		PowerUp.PowerUpType.DOUBLE_DASH:
			dash_charges = 2
	
	# Store powerups when they change
	PowerUpState.store_powerups(active_powerups)
