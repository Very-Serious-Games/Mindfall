class_name IdleState
extends State

var idle_timer: float = 0.0
var chance_to_agonize: float = 0.1
var check_interval: float = 2.0

func enter() -> void:
	if animation_tree:
		animation_tree.set("parameters/idle/blend_amount", 1.0)
		animation_tree.set("parameters/running/blend_amount", 0.0)
		animation_tree.set("parameters/attack/blend_amount", 0.0)
		animation_tree.set("parameters/agonizing/blend_amount", 0.0)
		animation_tree.set("parameters/death/blend_amount", 0.0)

func update(delta: float) -> void:
	idle_timer += delta
	if idle_timer >= check_interval:
		idle_timer = 0.0
		if randf() < chance_to_agonize:
			enemy.state_machine.change_state(enemy.agonizing_state)
