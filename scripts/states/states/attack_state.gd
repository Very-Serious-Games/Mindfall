class_name AttackState
extends State

var damage: float = 20.0
var attack_range: float = 2.0
var attack_cooldown: float = 1.5
var current_cooldown: float = 0.0

func enter() -> void:
	if animation_tree:
		animation_tree.set("parameters/attack/blend_amount", 1.0)
		animation_tree.set("parameters/idle/blend_amount", 0.0)
		animation_tree.set("parameters/running/blend_amount", 0.0)
		animation_tree.set("parameters/agonizing/blend_amount", 0.0)
		animation_tree.set("parameters/death/blend_amount", 0.0)

func update(delta: float) -> void:
	current_cooldown -= delta
	
	if current_cooldown <= 0:
		var distance = enemy.global_position.distance_to(enemy.player.global_position)
		if distance <= attack_range:
			enemy.player.take_damage(damage)
			current_cooldown = attack_cooldown
		else:
			enemy.state_machine.change_state(enemy.running_state)
