class_name PowerUpPickup extends Area3D

@export var powerup_type: PowerUp.PowerUpType

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.powerup_manager.activate_powerup(powerup_type)
		AudioManager.play_sound_3d("pickup_item", position)
		queue_free()
