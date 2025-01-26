class_name State
extends Node

var animation_tree: AnimationTree
var enemy: CharacterBody3D

func _init(enemy_node: CharacterBody3D, anim_tree: AnimationTree = null):
	enemy = enemy_node
	animation_tree = anim_tree

func enter() -> void:
	pass

func exit() -> void:
	pass
	
func update(delta: float) -> void:
	pass
