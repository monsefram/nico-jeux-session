extends Area2D

@export var value: int = 1
@export var pickup_sound: AudioStream

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

signal picked(value: int)

func _ready():
	anim.play("spin")  # démarrage de l'animation
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Car":
		emit_signal("picked", value)

		if pickup_sound:
			audio.stream = pickup_sound
			audio.play()

		await get_tree().create_timer(0.1).timeout
		queue_free()
