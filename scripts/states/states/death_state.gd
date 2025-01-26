class_name DeathState 
extends State

var death_animation_time: float = 2.0
var current_time: float = 0.0

func enter() -> void:
	if animation_tree:
		# Get the state machine playback
		var state_machine = animation_tree.get("parameters/playback")
		# Travel to death animation state
		state_machine.travel("death")
		# Ensure other animations are disabled
		animation_tree.set("parameters/conditions/is_dead", true)
		
		# Disable physics process and collision for main enemy body
		enemy.collision_layer = 0
		enemy.collision_mask = 0
		
		# Disable collision for static body
		var static_body = enemy.get_node("enemy/Armature/Skeleton3D/Alpha_Surface/StaticBody3D")
		if static_body:
			static_body.collision_layer = 0
			static_body.collision_mask = 0

func update(delta: float) -> void:
	current_time += delta
	if current_time >= death_animation_time:
		enemy.queue_free()
