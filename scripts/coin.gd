extends Area2D

@export var value: int = 1

@onready var coin: AnimatedSprite2D = $AnimatedSprite2D

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
		
		var hud = get_tree().get_first_node_in_group("hud")
		if hud:
			hud.add_coins(value)
		

		coin.visible = false
		await pickup_sound.finished
		queue_free()
