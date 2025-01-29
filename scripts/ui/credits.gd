extends Control

const SPEED_MULTIPLIER: float = 2.0
const MAIN_MENU_SCENE: String = "res://scenes/ui/main_menu.tscn"

@onready var scroll: ScrollContainer = $MarginContainer/TextureRect2/ScrollContainer
@onready var rich_text: RichTextLabel = $MarginContainer/TextureRect2/ScrollContainer/RichTextLabel

func _ready() -> void:
	# More initial spacing for smooth start
	rich_text.text = "[center]\n[color=#ffffff]\n\n\n\n\n\n\n\n\n\n\n" + rich_text.text
	await get_tree().process_frame
	scroll.get_v_scroll_bar().modulate.a = 0  # Hide scrollbar

func return_to_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _on_main_menu_butotn_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
