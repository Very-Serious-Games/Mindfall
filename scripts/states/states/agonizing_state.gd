extends State
class_name AgonizingState

var movement_penalty: float = 0.5
var attack_penalty: float = 0.7
var recovery_time: float = 5.0
var current_time: float = 0.0

func enter() -> void:
	if animation_tree:
		# Set agonizing animation as active
		animation_tree.set("parameters/agonizing/blend_amount", 1.0)
		# Disable other animations
		animation_tree.set("parameters/idle/blend_amount", 0.0)
		animation_tree.set("parameters/running/blend_amount", 0.0)
		animation_tree.set("parameters/attack/blend_amount", 0.0)
		animation_tree.set("parameters/death/blend_amount", 0.0)
	current_time = 0.0

func update(delta: float) -> void:
	current_time += delta
	if current_time >= recovery_time:
		# Return to normal state
		current_time = 0.0
