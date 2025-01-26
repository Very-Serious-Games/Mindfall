class_name Enemy
extends CharacterBody3D

@onready var player: Player = get_tree().get_first_node_in_group("player") # Fix group name case
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: StateMachine = StateMachine.new()
@onready var damageable: DamageableObject = $enemy/Armature/Skeleton3D/Alpha_Surface/StaticBody3D

# States
var idle_state: IdleState
var agonizing_state: AgonizingState  
var running_state: RunningState
var attack_state: AttackState
var death_state: DeathState

func _ready() -> void:
	add_child(state_machine)
	
	# Initialize states
	idle_state = IdleState.new(self, animation_tree)
	agonizing_state = AgonizingState.new(self, animation_tree)
	running_state = RunningState.new(self, animation_tree)  
	attack_state = AttackState.new(self, animation_tree)
	death_state = DeathState.new(self, animation_tree)
	
	# Connect damageable died signal
	damageable.died.connect(_on_died)
	
	state_machine.change_state(idle_state)

func _physics_process(delta: float) -> void:
	state_machine.update(delta)

func take_damage(amount: float) -> void:
	damageable.take_damage(amount)

func _on_died() -> void:
	state_machine.change_state(death_state)

func is_player_in_frustum() -> bool:
	var camera = get_viewport().get_camera_3d()
	if !camera:
		return false
	return camera.is_position_in_frustum(global_position)

func is_in_melee_range() -> bool:
	if !player:
		return false
	return global_position.distance_to(player.global_position) < 2.0
