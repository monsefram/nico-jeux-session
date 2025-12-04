extends Area2D



func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("ground"):
		# Appelle la fonction respawn sur le parent (car)
		#get_parent()._respawn()
		#get_node("./Gameover").game_over()
		var go = get_tree().get_first_node_in_group("gameover")
		if go:
			go.game_over()
