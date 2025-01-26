class_name RunningState
extends State

@onready var nav_agent: NavigationAgent3D = enemy.get_node("NavigationAgent3D")
@onready var raycast: RayCast3D = enemy.get_node("RayCast3D")

var speed: float = 5.0
var path_update_interval: float = 0.5
var path_timer: float = 0.0

func enter() -> void:
	if animation_tree:
		animation_tree.set("parameters/running/blend_amount", 1.0)
		animation_tree.set("parameters/idle/blend_amount", 0.0)
		animation_tree.set("parameters/attack/blend_amount", 0.0)
		animation_tree.set("parameters/agonizing/blend_amount", 0.0)
		animation_tree.set("parameters/death/blend_amount", 0.0)

func update(delta: float) -> void:
	var player = enemy.player
	if !player:
		return
		
	path_timer += delta
	if path_timer >= path_update_interval:
		path_timer = 0.0
		
		# Check line of sight
		raycast.look_at(player.global_position)
		if !raycast.is_colliding() or raycast.get_collider() == player:
			nav_agent.set_target_position(player.global_position)
			
	if nav_agent.is_navigation_finished():
		return
		
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - enemy.global_position).normalized()
	enemy.velocity = direction * speed
	enemy.move_and_slide()
