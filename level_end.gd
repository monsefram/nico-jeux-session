extends Area2D

# Chemin de la scène suivante (ex: "res://levels/level2.tscn")
@export var next_scene_path: String = "res://levels.tscn"
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# connecte le signal quand un corps entre dans la zone
	body_entered.connect(_on_body_entered)
	anim.play("default")


func _on_body_entered(body: Node) -> void:
	# On vérifie que c'est bien la voiture
	if not body.is_in_group("car"):
		return

	if next_scene_path == "":
		push_warning("next_scene_path n'est pas défini pour LevelEnd !")
		return
	get_tree().change_scene_to_file(next_scene_path)
