extends Control

const SCROLL_SPEED: float = 130.0
const SPEED_MULTIPLIER: float = 2.0
const MAIN_MENU_SCENE: String = "res://scenes/ui/main_menu.tscn"

@onready var scroll: ScrollContainer = $ScrollContainer
@onready var rich_text: RichTextLabel = $ScrollContainer/RichTextLabel
var scroll_speed: float = SCROLL_SPEED
var max_scroll: float = 0.0

func _ready() -> void:
	# More initial spacing for smooth start
	rich_text.text = "[center]\n[color=#ffffff]\n\n\n\n\n\n\n\n\n\n\n" + rich_text.text
	await get_tree().process_frame
	max_scroll = scroll.get_v_scroll_bar().max_value
	scroll.get_v_scroll_bar().modulate.a = 0  # Hide scrollbar

func _process(delta: float) -> void:
	scroll.scroll_vertical += scroll_speed * delta
	
	if scroll.scroll_vertical >= max_scroll or Input.is_action_just_pressed("ui_cancel"):
		return_to_menu()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			#scroll_speed = SCROLL_SPEED * SPEED_MULTIPLIER
			pass
		else:
			scroll_speed = SCROLL_SPEED

func return_to_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func _on_main_menu_butotn_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
