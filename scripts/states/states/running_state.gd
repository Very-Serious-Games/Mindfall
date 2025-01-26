class_name RunningState
extends State

@export var speed: float = 2.0
@export var acceleration: float = 10.0
@export var chase_distance: float = 20.0

var nav_agent: NavigationAgent3D
var gravity: float = -9.8
var vertical_velocity: float = 0.0

func _ready():
	set_physics_process(false)
	await get_tree().physics_frame
	set_physics_process(true)

func enter() -> void:
	nav_agent = enemy.get_node("NavigationAgent3D")
	if !nav_agent:
		push_error("NavigationAgent3D not found in enemy")
		return
		
	# Set animation
	if animation_tree:
		animation_tree.set("parameters/running/blend_amount", 1.0)
		animation_tree.set("parameters/idle/blend_amount", 0.0)
		animation_tree.set("parameters/attack/blend_amount", 0.0)
		animation_tree.set("parameters/agonizing/blend_amount", 0.0)
		animation_tree.set("parameters/death/blend_amount", 0.0)

func update(delta: float) -> void:
	if !nav_agent or !enemy.player:
		return

	# Check distance to player
	var distance_to_player = enemy.global_position.distance_to(enemy.player.global_position)
	if distance_to_player > chase_distance:
		enemy.velocity = Vector3.ZERO
		return
		
	# Update navigation target
	nav_agent.target_position = enemy.player.global_position
	
	# Calculate movement direction
	var direction = nav_agent.get_next_path_position() - enemy.global_position
	direction = direction.normalized()
	
	# Apply horizontal movement with smooth acceleration
	var target_velocity = direction * speed
	enemy.velocity = enemy.velocity.lerp(target_velocity, acceleration * delta)
	
	# Apply gravity
	if !enemy.is_on_floor():
		vertical_velocity += gravity * delta
	else:
		vertical_velocity = 0
	enemy.velocity.y = vertical_velocity
	
	# Move enemy
	enemy.move_and_slide()

func exit() -> void:
	enemy.velocity = Vector3.ZERO
	if animation_tree:
		animation_tree.set("parameters/running/blend_amount", 0.0)
