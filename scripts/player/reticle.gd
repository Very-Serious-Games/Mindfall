# Modified reticle.gd
extends CenterContainer

@export var RETICLE_LINES : Array[Line2D]
@export var PLAYER_CONTROLLER : CharacterBody3D
@export var RETICLE_SPEED : float = 0.25
@export var RETICLE_DISTANCE : float = 2.0
@export var DOT_RADIUS : float = 1.0 
@export var DOT_COLOR : Color = Color.WHITE
@export var HITMARKER_COLOR : Color = Color.RED
@export var HITMARKER_DURATION : float = 0.15
@export var HITMARKER_SIZE : float = 10.0

var hitmarker_alpha : float = 0.0
var hitmarker_scale : float = 1.0
var hitmarker_active : bool = false
var hitmarker_timer : float = 0.0

func _ready():
	queue_redraw()
	
	# Connect to player's hit signal
	PLAYER_CONTROLLER.connect("enemy_hit", Callable(self, "show_hitmarker"))
	
func _process(delta):
	adjust_reticle_lines()
	update_hitmarker(delta)
	queue_redraw()

func _draw():
	draw_circle(Vector2(0,0), DOT_RADIUS, DOT_COLOR)
	
	if hitmarker_active:
		var color = HITMARKER_COLOR
		color.a = hitmarker_alpha
		var size = HITMARKER_SIZE * hitmarker_scale
		
		# Draw hitmarker lines
		draw_line(Vector2(-size, -size), Vector2(-size/2, -size/2), color, 2.0)
		draw_line(Vector2(size, -size), Vector2(size/2, -size/2), color, 2.0)
		draw_line(Vector2(-size, size), Vector2(-size/2, size/2), color, 2.0)
		draw_line(Vector2(size, size), Vector2(size/2, size/2), color, 2.0)

func adjust_reticle_lines():
	var vel = PLAYER_CONTROLLER.get_real_velocity()
	var origin = Vector3(0,0,0)
	var pos = Vector2(0,0)
	var speed = origin.distance_to(vel)
	
	RETICLE_LINES[0].position = lerp(RETICLE_LINES[0].position, pos + Vector2(0, -speed * RETICLE_DISTANCE), RETICLE_SPEED)
	RETICLE_LINES[1].position = lerp(RETICLE_LINES[1].position, pos + Vector2(speed * RETICLE_DISTANCE, 0), RETICLE_SPEED)
	RETICLE_LINES[2].position = lerp(RETICLE_LINES[2].position, pos + Vector2(0, speed * RETICLE_DISTANCE), RETICLE_SPEED)
	RETICLE_LINES[3].position = lerp(RETICLE_LINES[3].position, pos + Vector2(-speed * RETICLE_DISTANCE, 0), RETICLE_SPEED)

func show_hitmarker():
	hitmarker_active = true
	hitmarker_timer = HITMARKER_DURATION
	hitmarker_alpha = 1.0
	hitmarker_scale = 1.2

func update_hitmarker(delta):
	if hitmarker_active:
		hitmarker_timer -= delta
		hitmarker_alpha = lerp(hitmarker_alpha, 0.0, 10.0 * delta)  
		hitmarker_scale = lerp(hitmarker_scale, 1.0, 10.0 * delta)

		if hitmarker_timer <= 0:
			hitmarker_active = false
			hitmarker_alpha = 0.0
			hitmarker_scale = 1.0
