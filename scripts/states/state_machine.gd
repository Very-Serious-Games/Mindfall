class_name StateMachine
extends Node

var current_state: State
var previous_state: State

func change_state(new_state: State) -> void:
	print("Changing state to: ", new_state.get_class())
	if current_state:
		current_state.exit()
		previous_state = current_state
		
	current_state = new_state
	current_state.enter()

func update(delta: float) -> void:
	if current_state:
		print("StateMachine: Updating state ", current_state.get_class())
		current_state.update(delta)
