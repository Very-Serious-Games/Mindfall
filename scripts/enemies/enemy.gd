extends CharacterBody3D


var player = null
var state_machine
var health = 5
var can_attack = true

const SPEED = 4.0
const ATTACK_RANGE = 2.0
const DETECT_RANGE = 50.0
const AGONIZE_CHANGE = 0.05
const ATTACK_COOLDOWN = 1.0

@export var player_path := "/root/Level1/NavigationRegion3D/Player"

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree


# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"running":
			# Navigation
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z) + PI, delta * 10.0)
		"attack":
			if _target_in_range():
				look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
				rotation.y += PI
				if can_attack:
					_perform_attack()
			else:
				# Exit attack state if player moves away
				anim_tree.set("parameters/conditions/attack", false)
				anim_tree.set("parameters/conditions/run", true)
	
	# Conditions
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	#anim_tree.set("parameters/conditions/run", !_target_in_range())
	anim_tree.set("parameters/conditions/detect_player", _detect_player())
	anim_tree.set("parameters/conditions/lost_player", !_detect_player())
	# anim_tree.set("parameters/conditions/agonize", _start_agonizing())
	
	move_and_slide()

func _perform_attack():
	can_attack = false
	anim_tree.set("parameters/conditions/attack", true)
	var timer = get_tree().create_timer(ATTACK_COOLDOWN)
	await timer.timeout
	anim_tree.set("parameters/conditions/attack", false)
	anim_tree.set("parameters/conditions/run", true)
	can_attack = true

func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE
	
func _detect_player():
	return global_position.distance_to(player.global_position) < DETECT_RANGE
	
func _start_agonizing():
	return randf() < AGONIZE_CHANGE

func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)

func _on_area_3d_body_part_hit(damage):
	health -= damage
	if health <= 0:
		anim_tree.set("parameters/conditions/die", true)
		await get_tree().create_timer(3.0).timeout
		queue_free()
