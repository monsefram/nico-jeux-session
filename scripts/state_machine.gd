extends Node

enum {
	STATE_NORMAL,
	STATE_REWIND,
}

var current_state: int = STATE_NORMAL

func set_state(new_state: int) -> void:
	current_state = new_state

func is_state(test_state: int) -> bool:
	return current_state == test_state
