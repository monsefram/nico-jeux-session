extends Area2D

@export var value: int = 1

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var pickup_sound: AudioStreamPlayer2D = $pickup_sound

signal picked(value: int)

func _ready():
	anim.play("spin")  # démarrage de l'animation
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "car":
		emit_signal("picked", value)
		pickup_sound.play()

		await get_tree().create_timer(0.1).timeout
		queue_free()
